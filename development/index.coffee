os = require 'os'
child_process = require 'child_process'

###*
 * Reg Match All
 * @param  {String} str - проверяемая строка
 * @param  {Object} reg - регулярное выражение
 * @return {Object} marches - результаты поиска
###
regMatchAll = (str, reg)->
    results = []

    while (arr = reg.exec str) != null
        results.push arr

    return results

_diskSpace = (async=true, callback=undefined, phSystem=undefined, phOutput=undefined)->
    osType = os.type()

    # Windows
    _parseWindowOutp = (str)->
        disks = {
            total:
                free:       0
                size:       0
                used:       0
                percent:    0
            disks: {}
        }

        reg = /([a-z0-9]):(?:\ |\t)*([0-9]+)(?:\ |\t)*([0-9]+)/gi

        matches = regMatchAll str, reg

        for disk in matches
            name = disk[1]
            free = parseInt disk[2]
            size = parseInt disk[3]
            used = size - free
            percent = used / size

            # Добавление диска
            disks.disks[ name ] = {
                free
                size
                used
                percent
            }

            # Подсчет общей статистики
            disks.total.free +=     free
            disks.total.size +=     size
            disks.total.used +=     used

        disks.total.percent = disks.total.used / disks.total.size

        return disks

    # OSX
    _parseOsxOutp = (str)->
        disks = {
            total:
                free:       0
                size:       0
                used:       0
                percent:    0
            disks: {}
        }

        reg = /([a-z0-9\/_-]+)(?:\ |\t)*([0-9]+)(?:\ |\t)*([0-9]+)(?:\ |\t)*([0-9]+)(?:\ |\t)*([0-9]+)%(?:\ |\t)*([0-9]+)(?:\ |\t)*([0-9]+)(?:\ |\t)*([0-9]+)%(?:\ |\t)*([a-z0-9 \/_-]+)/gi

        matches = regMatchAll str, reg

        for disk in matches
            name = disk[9]
            used = parseInt disk[3]
            size = parseInt disk[2]
            free = size - used

            percent = used / size

            # Добавление диска
            disks.disks[ name ] = {
                free
                size
                used
                percent
            }

            # Подсчет общей статистики
            disks.total.free +=   free
            disks.total.size +=   size
            disks.total.used +=   used

        disks.total.percent = disks.total.used / disks.total.size

        return disks

    # Linux
    _parseLinuxOutp = (str)->
        disks = {
            total:
                free:       0
                size:       0
                used:       0
                percent:    0
            disks: {}
        }

        reg = /([a-z0-9\/_-]+)(?:\ |\t)*([0-9]+)(?:\ |\t)*([0-9]+)(?:\ |\t)*([0-9]+)(?:\ |\t)*([0-9]+)%(?:\ |\t)*([a-z0-9 \/_-]+)/gi

        matches = regMatchAll str, reg

        for disk in matches
            name = disk[6]
            used = parseInt disk[3]
            size = parseInt disk[2]
            free = size - used

            percent = used / size

            # Добавление диска
            disks.disks[ name ] = {
                free
                size
                used
                percent
            }

            # Подсчет общей статистики
            disks.total.free +=   free
            disks.total.size +=   size
            disks.total.used +=   used

        disks.total.percent = disks.total.used / disks.total.size

        return disks

    # Init
    #- Windows
    if (osType == 'Windows_NT' && !phSystem) || phSystem == 'Windows_NT'
        # Async version
        if async 
            unless phOutput
                child_process.exec 'wmic logicaldisk get size,freespace,caption', (error, stdout, stderr)->
                    if error then return callback error, null

                    return callback null, _parseWindowOutp stdout
            else
                return callback null, _parseWindowOutp phOutput
        # Sync version
        else
            unless phOutput
                stdout = child_process.execSync('wmic logicaldisk get size,freespace,caption',  {stdio: 'pipe'}).toString()
            else
                stdout = phOutput

            return _parseWindowOutp stdout

    #- OSX
    else if (osType == 'Darwin' && !phSystem) || phSystem == 'Darwin'
        # Async version
        if async
            unless phOutput
                child_process.exec 'df -k', (error, stdout, stderr)->
                    if error then return callback error, null

                    return callback null, _parseOsxOutp stdout
            else
                return callback null, _parseOsxOutp phOutput
        # Sync version
        else
            unless phOutput
                stdout = child_process.execSync('df -k',  {stdio: 'pipe'}).toString()
            else
                stdout = phOutput

            return _parseOsxOutp stdout

    #- Linux
    else
        # Async version
        if async 
            unless phOutput
                child_process.exec 'df -k', (error, stdout, stderr)->
                    if error then return callback error, null

                    return callback null, _parseLinuxOutp stdout
            else
                return callback null, _parseLinuxOutp phOutput
        # Sync version
        else
            unless phOutput
                stdout = child_process.execSync('df -k',  {stdio: 'pipe'}).toString()
            else
                stdout = phOutput

            return _parseLinuxOutp stdout

###*
 * Sync check disk space
 * @param  {String}     phOutput            - Std output, only for tests
 * @param  {String}     phSystem            - System, only for tests
 * 
 * @return {Object}     disks               - info about disk
 * @return {Object}     disks.total         - sum of all disk space
 * @return {Integer}    disks.total.free    - free disk space
 * @return {Integer}    disks.total.size    - total size of disk
 * @return {Integer}    disks.total.used    - used disk space
 * @return {Integer}    disks.total.percent - percent of used disk space
 *
 * @return {Object}     disks.disks         - named disks. Contain full analogue disks.total Object
###
diskSpaceSync = (phSystem=undefined, phOutput=undefined)->
    return _diskSpace(false, null, phSystem, phOutput)

###*
 * Sync check disk space
 * @param  {Callback}   callback            - Callback function
 * @param  {Error}      callback.err        - Callback function error
 * @param  {Object}     callback.res        - Callback function result about disk space
 * 
 * @param  {String}     phOutput            - Std output, only for tests
 * @param  {String}     phSystem            - System, only for tests
 * 
 * @return {Object}     disks               - info about disk
 * @return {Object}     disks.total         - sum of all disk space
 * @return {Integer}    disks.total.free    - free disk space
 * @return {Integer}    disks.total.size    - total size of disk
 * @return {Integer}    disks.total.used    - used disk space
 * @return {Integer}    disks.total.percent - percent of used disk space
 *
 * @return {Object}     disks.disks         - named disks. Contain full analogue disks.total Object
###
diskSpace = (callback, phSystem=undefined, phOutput=undefined)->
    return _diskSpace(true, callback, phSystem, phOutput)

module.exports = {
    diskSpace
    diskSpaceSync
}
