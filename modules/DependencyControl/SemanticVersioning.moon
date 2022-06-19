
class SemanticVersioning
    semParts = {{"major", 16}, {"minor", 8}, {"patch", 0}}

    msgs = {
        parse: {
            badString: "Can't parse version string '%s'. Make sure it conforms to semantic versioning standards."
            badType: "Argument had the wrong type: expected a string or number, got a %s. Content %s"
            overflow: "Error: %s version must be an integer < 255, got %s."
        }
    }

    @parse = (value) =>
        switch type value
            when "number" then return math.max value, 0
            when "nil" then return 0
            when "string"
                matches = {value\match "^(%d+).(%d+).(%d+)$"}
                if #matches!=3
                    return false, msgs.parse.badString\format value

                version = 0
                for i, part in ipairs semParts
                    value = tonumber(matches[i])
                    if type(value) != "number" or value>256
                        return false, msgs.parse.overflow\format part[1], tostring value
                    version += bit.lshift value, part[2]
                return version

            else return false, msgs.parse.badType\format type(value), @logger\dumpToString value

    @toString = (version, precision = "patch") =>
        if type(version) == "string"
            version = @parse version
        parts = {0, 0, 0}
        for i, part in ipairs semParts
            parts[i] = bit.rshift(version, part[2])%256
            break if precision == part[1]

        return "%d.%d.%d"\format unpack parts


    @check = (@version, value) =>
        if type(value) != "number"
            value, err = @parse value
            return nil, err unless value
        mask = 0
        for part in *semParts
            mask += 0xFF * 2^part[2]
            break if precision == part[1]

        value = bit.band value, mask
        version = @parse version
        return version >= value, value