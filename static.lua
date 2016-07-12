local lfs = require "lfs"
local markdown = require "markdown"

local config = {
    templatefile="template.html",
    inputdir="data",
    outputdir="out"
}

function generatepost (templatedata, id, title, date, content)
    
    -- Simple template format, just find + replace
    local dat = templatedata
    dat = string.gsub(dat, "#{id}", id)
    dat = string.gsub(dat, "#{title}", title)
    dat = string.gsub(dat, "#{date}", date)
    dat = string.gsub(dat, "#{content}", content)

    return dat
end

function parseposts (conf)

    -- Read in template data
    local f = io.open(conf.templatefile, "r")
    local templatedata = f:read("*a")
    f:close()

    for file in lfs.dir(conf.inputdir) do
        if file ~= "." and file ~= ".." then
            local filepath = conf.inputdir..'/'..file

            -- Read in the file
            f = io.open(filepath, "r")

            -- First line is the # of the post, second is the title, third is date
            local id = f:read()
            local title = f:read()
            local date = f:read()
            local content = markdown(f:read("*a"))

            f:close()

            -- Generate the final blog post
            local final = generatepost(templatedata, id, title, date, content) 

            -- Save blog post to output directory using only alphanumeric characters
            f = io.open("out/"..string.gsub(string.gsub(title:lower(), "[^%w]", ""), " ", "-"), "w")
            f:write(final)
            f:close()

            print ("\t "..filepath)
        end
    end
end

print("[*] lua static site generator")

-- Check if our template file exists
if lfs.attributes(config.templatefile) == nil then
    print("[ERR] Templates file "..config.templatefile.." does not exist!")
    return
end

-- Create output/input directories if they don't exist
if lfs.attributes(config.inputdir) == nil then
    local a, b = lfs.mkdir(config.inputdir)
    if a == nil then
        print("[ERR] "..b)
        return
    end
end
if lfs.attributes(config.outputdir) == nil then
    local a, b = lfs.mkdir(config.outputdir)
    if a == nil then
        print("[ERR] "..b)
        return
    end
end

print("[*] Using "..config.templatefile.." as page template")
print("[*] Parsing markdown files in "..config.inputdir)
print("[*] Saving output to "..config.outputdir)
parseposts (config)
print("[*] Done!")
