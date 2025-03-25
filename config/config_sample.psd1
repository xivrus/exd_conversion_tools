# Rename me to config.psd1

@{
    PATHS = @{
        # Full path to FFXIV installation folder
        # Tip: You don't need ALL of the files.
        # The bare minimum for dumping EXH/EXDs:
        # - <ffxiv_version>
        #   - game
        #     - sqpack
        #       - ffxiv
        #         - 0a0000.win32.dat0
        #         - 0a0000.win32.index
        #         - 0a0000.win32.index2
        #     - ffxivgame.ver
        # This path is used by dumping script in read-only mode.
        DUMP_EXTRACTED_DIR = './dump/extracted'

        # Full path to the folder where the dumps would live.
        # Note that internal versioning of the game is not the same
        # as the marketed one. Meaning you won't see short numbers,
        # such as 6.58, 7.0, etc.
        # Also note that this folder is also used by non-dumping
        # scripts, but in read-only mode.
        DUMP_RAW_DIR = './dump/raw'

        # Full path to the folder where the strings files should be saved.
        STRINGS_DIR = './strings'

        # Full path to the folder where the output should be saved.
        # Output includes:
        #   * Modded EXDs
        # The structure of the files is preserved so that creating
        # a Penumbra modpack would be a simple matter of zipping a folder
        # (and generating and adding metadata files).
        OUTPUT_DIR = './output'

        # Full path to the cache folder.
        # Cache includes:
        #   * Files with timestamps of strings files that were previously
        #     converted so that during mass conversion the scripts
        #     would not touch the files that didn't change
        CACHE_DIR = './cache'
    }

    # One of the official languages that you want to translate
    # the game from.
    # During the update if this language file was changed, all
    # non-official languages would be due to update as well.
    # Also all new strings would be taken from this language.
    MAIN_SOURCE_LANGUAGE = 'en'

    # Note: Turning verbosity on will slow down the scripts.
    VERBOSE = $false
}
