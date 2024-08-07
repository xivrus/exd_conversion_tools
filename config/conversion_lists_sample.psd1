@{
    # (NOT IMPLEMENTED)
    # Allows to explicitly add IDs at the start of all strings in specified file(s)
    # for debugging/searching purposes.
    #
    # Cache is removed for these files so that they would be re-converted normally
    # when they're removed from this list. If a string already has its ID at the start,
    # it won't be re-added again.
    #
    # For dialog files (with 2 columns where 1st column starts with TEXT_) IDs are added
    # after the column separator.
    ADD_IDS = @(

    )

    # During update:
    # In what files the update script should add index at the start of
    # the updated strings?
    #
    # E.g. Old translation string = "String A"
    #      New translation string = "91_String B" where 91 is index
    ADD_IDS_ON_UPDATE = @(

    )

    # What quest files should be included? The quest files are considered
    # to be files in game folders:
    #   exd/cut_scene
    #   exd/opening
    #   exd/quest
    # Each entry in the list should be an EXH file name w/o '.exh', e.g. 'JobDrg300_01067'
    # If this list is empty, all files are included.
    INCLUDE_QUESTS = @(

    )

    # File splitting
    #
    # Some of the game files (e.g. 'Item', 'Status') have both name and description
    # in one file. If you want to keep names and descriptions separated, this
    # feature should prove to be useful.
    # The syntax is following:
    #
    #   <original_file_name> = @{
    #       <new_file_name_1> = @{
    #           Columns = @( <column_1>[,<column_2>[...]] )
    #           [Language = <language_1>]
    #       }
    #       <new_file_name_2> = @{
    #           Columns = @( <column_3>[,<column_4>[...]] )
    #           [Language = <language_2>]
    #       }
    #       [...]
    #   }
    #
    # Here, file 'Item' will be split in two files: 'ItemName' and 'ItemTransient'.
    # 'ItemName' will have columns 0, 1, and 3, while 'ItemTransient' will only have column 2.
    # You can have as many files and columns as you need. If a column is not mentioned in any
    # of defined files, it will be dropped. First column number is 0.
    #
    # You can also specify what strings language to take during conversion to game data.
    # If 'Language' is not defined, script language will be taken. Thus, in our example ItemName
    # would be from EN file, while ItemTransient would be from the language that was specified
    # during the script call.
    #
    # Strings files for each new file will be put inside original one. In the example above,
    # 'Item' folder will have new folders 'ItemName' and 'ItemTransient'. Each of the nested
    # folders would have their respective strings files.
    #
    # Note 1: 'Column number' refers to _string_ column number, not an actual column number
    #         in the file.
    # Note 2: This won't split existing full strings files. You'll have to do it yourself
    #         or redo a conversion from EXD.
    # Note 3. The feature works only in ConvertFrom-GameData and ConvertAllStringsToGameData
    #         (splitting/combining). This feature DOES NOT work in ConvertTo-GameData.
    SPLIT_FILES = @{
        Item = @{
            ItemName = @{
                Columns = @( 0, 1, 3 )
                Language = 'en'
            } 
            ItemTransient = @{
                Columns = @( 2 )
            }
        }
    }
}
