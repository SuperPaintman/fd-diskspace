assert          = require 'assert'
diskspace       = require '../index.js'

# OSX
osxOutp = """
            Filesystem     1K-blocks    Used Available Capacity iused    ifree %iused  Mounted on
            /dev/vda3       30572556 6924844  22088060    24% 5813733 11077050   23%   /
            tmpfs             251044       0    251044    0%        0   140033    0%   /dev/shm
            /dev/vda1         245679   70431    162141    31%   60320   151030   30%   /boot
            """
osxCanonicity = {
    total:
        free: 24074004
        size: 31069279
        used: 6995275
        percent: 0.22515086365538126
    disks:
        '/':
            free: 23647712
            size: 30572556
            used: 6924844
            percent: 0.22650523561065683
        '/dev/shm':
            free: 251044
            size: 251044
            used: 0
            percent: 0
        '/boot':
            free: 175248
            size: 245679
            used: 70431
            percent: 0.28667895912959596
}


# Linux
linuxOutp = """
            Filesystem     1K-blocks    Used Available Use% Mounted on
            /dev/vda3       30572556 6924844  22088060  24% /
            tmpfs             251044       0    251044   0% /dev/shm
            /dev/vda1         245679   70431    162141  31% /boot
            """
linuxCanonicity = {
    total:
        free: 24074004
        size: 31069279
        used: 6995275
        percent: 0.22515086365538126
    disks:
        '/':
            free: 23647712
            size: 30572556
            used: 6924844
            percent: 0.22650523561065683
        '/dev/shm':
            free: 251044
            size: 251044
            used: 0
            percent: 0
        '/boot':
            free: 175248
            size: 245679
            used: 70431
            percent: 0.28667895912959596
}

# Windows
windowsOutp = """
                Caption  FreeSpace     Size
                C:       12878057472   94371835904
                D:       52760469504   314572795904
                E:       39574544384   99614715904
                F:       89581342720   314572795904
                G:       174223106048  314572795904
                I:
                J:
                K:
                L:       0             4536729600
                M:
                N:
                Z:       52760469504   314572795904
                """
windowsCanonicity = {
    total:
        free: 421777989632
        size: 1456814465024
        used: 1035036475392
        percent: 0.7104792684598642
    disks:
        C:
            free: 12878057472
            size: 94371835904
            used: 81493778432
            percent: 0.863539186785555
        D:
            free: 52760469504
            size: 314572795904
            used: 261812326400
            percent: 0.8322789821911326
        E:
            free: 39574544384
            size: 99614715904
            used: 60040171520
            percent: 0.6027239145856873
        F:
            free: 89581342720
            size: 314572795904
            used: 224991453184
            percent: 0.7152285770212055
        G:
            free: 174223106048
            size: 314572795904
            used: 140349689856
            percent: 0.4461596542468705
        L:
            free: 0
            size: 4536729600
            used: 4536729600
            percent: 1
        Z:
            free: 52760469504
            size: 314572795904
            used: 261812326400
            percent: 0.8322789821911326
}

unitTest = ->
    describe "diskspace", ->
        #OSX
        it "sync osx", ->
            assert.deepEqual diskspace.diskSpaceSync('Darwin', osxOutp), osxCanonicity
        #Linux
        it "sync linux", ->
            assert.deepEqual diskspace.diskSpaceSync('Linux', linuxOutp), linuxCanonicity
        # Windows
        it "sync window", ->
            assert.deepEqual diskspace.diskSpaceSync('Windows_NT', windowsOutp), windowsCanonicity

        #OSX
        it "async osx", ->
            diskspace.diskSpace (err, res)->
                assert.deepEqual res, osxCanonicity
            , 'Darwin', osxOutp
        #Linux
        it "async linux", ->
            diskspace.diskSpace (err, res)->
                assert.deepEqual res, linuxCanonicity
            , 'Linux', linuxOutp
        # Windows
        it "async window", ->
            diskspace.diskSpace (err, res)->
                assert.deepEqual res, windowsCanonicity
            , 'Windows_NT', windowsOutp
unitTest()
