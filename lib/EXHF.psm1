# This file contains EXHF class and its supplementary classes
using namespace System.Buffers.Binary

enum Lang_CodeValue {
	none = 0
    ja   = 1
    en   = 2
    de   = 3
    fr   = 4
    chs  = 5
    cht  = 6
    ko   = 7
    unknown = 8  # Appeared in 7.2. Exact language and its code are currently unknown.
}

[Flags()] enum LanguageCodes {
	none = 1
    ja   = 2
    en   = 4
    de   = 8
    fr   = 16
    chs  = 32
    cht  = 64
    ko   = 128
    unknown = 256
}

class EXHF {
    [string] $Path

    # EXH data
    static [uint32] $Signature = 0x45584846 # "EXHF"
    static [uint16] $Version = 0x0003
    [uint16] $SizeOfDatasetChunk
    [uint16] $Unknown1 # use GetUnknown1() to get value
    [uint32] $Unknown2 # use GetUnknown2() to get value
    [uint32] $NumberOfEntries
    $DatasetTable = [System.Collections.Generic.List[DatasetUnit]]::new()
    $PageTable = [System.Collections.Generic.SortedDictionary[uint32,PageUnit]]::new()
    [LanguageCodes] $DeclaredLanguages

    # Supplementary data
    [int[]] $StringDatasetOffsets


    EXHF([string]$Path) {
		$stream = [System.IO.FileStream]::new(
            $Path,
            [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Read
        )
		$reader = [System.IO.BinaryReader]::new($stream)

        $this.Path = $Path
		$sig = [BinaryPrimitives]::ReadUInt32BigEndian( $reader.ReadBytes(4) )
        if ($sig -ne [EXHF]::Signature) {
            throw [System.IO.InvalidDataException]::new(
                "Incorrect format: File signature is not EXHF."
            )
        }
        $ver = [BinaryPrimitives]::ReadUInt16BigEndian( $reader.ReadBytes(2) )
        if ($ver -ne [EXHF]::Version) {
            Write-Warning "Unexpected EXH version: {0} instead of {1}.`n`tFile: $Path" -f $ver, [EXHF]::Version
        }
        $this.SizeOfDatasetChunk = [BinaryPrimitives]::ReadUInt16BigEndian( $reader.ReadBytes(2) )
        $NumberOfDatasets =        [BinaryPrimitives]::ReadUInt16BigEndian( $reader.ReadBytes(2) )
        $NumberOfPages =           [BinaryPrimitives]::ReadUInt16BigEndian( $reader.ReadBytes(2) )
        $NumberOfLangCodes =       [BinaryPrimitives]::ReadUInt16BigEndian( $reader.ReadBytes(2) )
        $this.Unknown1 =           [BinaryPrimitives]::ReadUInt16BigEndian( $reader.ReadBytes(2) )
        $this.Unknown2 =           [BinaryPrimitives]::ReadUInt32BigEndian( $reader.ReadBytes(4) )
        $this.NumberOfEntries =    [BinaryPrimitives]::ReadUInt32BigEndian( $reader.ReadBytes(4) )
        
		$null = $reader.ReadBytes(8)

		foreach ($i in (1..$NumberOfDatasets)) {
            $type = [BinaryPrimitives]::ReadUInt16BigEndian( $reader.ReadBytes(2) )
            $offset = [BinaryPrimitives]::ReadUInt16BigEndian( $reader.ReadBytes(2) )

            $this.DatasetTable.Add( [DatasetUnit]::new($type, $offset) )
        }

        foreach ($i in (1..$NumberOfPages)) {
            $entry = [BinaryPrimitives]::ReadUInt32BigEndian( $reader.ReadBytes(4) )
            $size  = [BinaryPrimitives]::ReadUInt32BigEndian( $reader.ReadBytes(4) )
            $page = [PageUnit]::new( $this, $entry, $size )

            $this.PageTable.Add( $entry, $page )
        }

        foreach ($i in (1..$NumberOfLangCodes)) {
            # Crazy conversion chain, I know
			$this.DeclaredLanguages += [LanguageCodes] [string] [Lang_CodeValue] $reader.ReadUInt16()
		}

		$reader.Dispose()
		$stream.Dispose()
    }

    [uint16] GetNumberOfDatasets() {
        return $this.DatasetTable.Count
    }

    [uint16] GetNumberOfPages() {
        return $this.PageTable.Count
    }

    [uint16] GetNumberOfLangs() {
        return $this.DeclaredLanguages.Count
    }

    [DatasetUnit] GetDataset([int]$Number) {
        return $this.DatasetTable[$Number]
    }

    [int[]] GetStringDatasetOffsets() {
        if ($null -eq $this.StringDatasetOffsets) {
            $this.StringDatasetOffsets = foreach ($Dataset in $this.DatasetTable) {
                if ($Dataset.Type -eq 0x00) { $Dataset.Offset }
            }
            $this.StringDatasetOffsets = $this.StringDatasetOffsets | Sort-Object
        }
        return $this.StringDatasetOffsets
    }

	[bool] IsLanguageDeclared([string]$Language) {
		return $this.DeclaredLanguages.HasFlag([LanguageCodes]::$Language)
	}

    [string] GetEXDPath([int]$PageNumber, [string]$Language) {
        $base_exd_path = $this.Path -creplace '\.exh$', ''
        if ($Language -eq 'none') {
            $exd_path = "{0}_{1}.exd" -f $base_exd_path, $PageNumber
        } else {
            $exd_path = "{0}_{1}_{2}.exd" -f $base_exd_path, $PageNumber, $Language.ToLower()
        }

        return $exd_path
    }

    [void] Export([string]$Destination) {
		$stream = [System.IO.FileStream]::new(
            $Destination,
            [System.IO.FileMode]::Create,
            [System.IO.FileAccess]::Write
        )
		$writer = [System.IO.BinaryWriter]::new($stream)
		$bytes_uint32 = [byte[]](0x00) * 4
		$bytes_uint16 = [byte[]](0x00) * 2
        # Header
		[BinaryPrimitives]::WriteUInt32BigEndian($bytes_uint32, [EXHF]::Signature);              $writer.Write($bytes_uint32)
		[BinaryPrimitives]::WriteUInt16BigEndian($bytes_uint16, [EXHF]::Version);                $writer.Write($bytes_uint16)
		[BinaryPrimitives]::WriteUInt16BigEndian($bytes_uint16, $this.get_SizeOfDatasetChunk()); $writer.Write($bytes_uint16)
		[BinaryPrimitives]::WriteUInt16BigEndian($bytes_uint16, $this.GetNumberOfDatasets());    $writer.Write($bytes_uint16)
		[BinaryPrimitives]::WriteUInt16BigEndian($bytes_uint16, $this.GetNumberOfPages());       $writer.Write($bytes_uint16)
		[BinaryPrimitives]::WriteUInt16BigEndian($bytes_uint16, $this.GetNumberOfLangs());       $writer.Write($bytes_uint16)
		[BinaryPrimitives]::WriteUInt16BigEndian($bytes_uint16, $this.Unknown1);                 $writer.Write($bytes_uint16)
		[BinaryPrimitives]::WriteUInt32BigEndian($bytes_uint32, $this.Unknown2);                 $writer.Write($bytes_uint32)
		[BinaryPrimitives]::WriteUInt32BigEndian($bytes_uint32, $this.get_NumberOfEntries());    $writer.Write($bytes_uint32)
        $writer.Write([byte[]](0x00) * 8)
        # Dataset table
        foreach ($Dataset in $this.DatasetTable) {
			[BinaryPrimitives]::WriteUInt16BigEndian($bytes_uint16, $Dataset.get_Type());   $writer.Write($bytes_uint16)
			[BinaryPrimitives]::WriteUInt16BigEndian($bytes_uint16, $Dataset.get_Offset()); $writer.Write($bytes_uint16)
        }
        # Page table
        foreach ($Page in $this.PageTable) {
			[BinaryPrimitives]::WriteUInt32BigEndian($bytes_uint32, $Page.get_Entry()); $writer.Write($bytes_uint32)
			[BinaryPrimitives]::WriteUInt32BigEndian($bytes_uint32, $Page.get_Size());  $writer.Write($bytes_uint32)
        }
        # Language table
        foreach ($Lang in [Lang_CodeValue].GetEnumNames()) {
            if ($this.IsLanguageDeclared($Lang)) {
				$lang_uint16 = [uint16] [Lang_CodeValue]::$Lang
				$writer.Write( $lang_uint16 )
            }
        }
        # Done
		$writer.Dispose()
		$stream.Dispose()
    }
}

enum Dataset_NameByte {
	string   = 0x00
	bool     = 0x01
	byte     = 0x02
	ubyte    = 0x03
	short    = 0x04
	ushort   = 0x05
	int      = 0x06
	uint     = 0x07
	float    = 0x09
	int_x4   = 0x0B
	bitflags = 0x19
}

enum Dataset_NameRequiredBytes {
	string   = 4
	bool     = 1
	byte     = 1
	ubyte    = 1
	short    = 2
	ushort   = 2
	int      = 4
	uint     = 4
	float    = 4
	int_x4   = 8
	bitflags = 0
}

class DatasetUnit {
    [uint16] $Type
    [uint16] $Offset

    DatasetUnit([uint16]$Type, [uint16]$Offset) {
        $this.Type = $Type
        $this.Offset = $Offset
    }

    static [string] GetTypeNameByType([int]$Type) {
        return [Dataset_NameByte]$Type
    }
    
    static [int] GetTypeByTypeName([string]$TypeName) {
        return [Dataset_NameByte]::$($TypeName)
    }

    static [int] GetRequiredBytesByType([int]$Type) {
        return [Dataset_NameRequiredBytes]::$([DatasetUnit]::GetTypeNameByType($Type))
    }


    [string] get_TypeName() {
        return [DatasetUnit]::GetTypeNameByType($this.Type)
    }

    [int] get_RequiredBytes() {
        return [DatasetUnit]::GetRequiredBytesByType($this.Type)
    }
}

class PageUnit {
    [EXHF] $ExhRef
    [uint32] $Entry
    [uint32] $Size

    PageUnit([EXHF]$Exh, [uint32]$Entry, [uint32]$Size) {
        $this.ExhRef = $Exh
        $this.Entry = $Entry
        $this.Size = $Size
    }
}
