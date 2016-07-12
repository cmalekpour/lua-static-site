local lfs = require "lfs"
local markdown = require "markdown"

local config = {
    author="cmalekpour",
    templatefile="template.html",
    inputdir="data",
    outputdir="out"
}

function generatepost (conf, templatedata, id, title, date, content, titlemap)
    
    -- Simple template format, just find + replace
    local dat = templatedata
    dat = string.gsub(dat, "#{id}", id)
    dat = string.gsub(dat, "#{title}", title)
    dat = string.gsub(dat, "#{date}", date)
    dat = string.gsub(dat, "#{author}", conf.author)
    dat = string.gsub(dat, "#{content}", content)

    -- Generate link to next post (if it exists)
    if titlemap[id + 1] ~= nil then
        dat = string.gsub(dat, "#{nextpost}", titlemap[id + 1])
        dat = string.gsub(dat, "#{isnextpost}", "")
        dat = string.gsub(dat, "#{/isnextpost}", "")
    else
        dat = string.gsub(dat, "#{isnextpost}(.-)#{/isnextpost}", "")
    end

    -- Generate link to prev post (if it exists)
    if titlemap[id - 1] ~= nil then
        dat = string.gsub(dat, "#{prevpost}", titlemap[id - 1])
        dat = string.gsub(dat, "#{isprevpost}", "")
        dat = string.gsub(dat, "#{/isprevpost}", "")
    else
        dat = string.gsub(dat, "#{isprevpost}(.-)#{/isprevpost}", "")
    end

    return dat
end

function sanitizetitle(title)
    return string.gsub(string.gsub(title:lower(), "[^%w]", ""), " ", "-")
end

function parseposts (conf)

    -- Read in template data
    local f = io.open(conf.templatefile, "r")
    local templatedata = f:read("*a")
    f:close()

    -- Posts are processed in two passes. The first pass maps post titles to
    -- their IDs, which allows us to create forward/reverse links. The second
    -- pass actually processes the post content

    -- Titlemap maps ids -> titles
    local titlemap = {}

    -- This is just a list of all post titles
    local titles = {}

    for file in lfs.dir(conf.inputdir) do
        if file ~= "." and file ~= ".." then
            local filepath = conf.inputdir..'/'..file

            -- We only care about the first two lines (ID and title)
            local f = io.open(filepath, "r")
            local id = tonumber(f:read())
            local title = f:read()
            f:close()

            if titles[title] ~= nil then
                print("[ERR] Duplicate post title "..title)
                print("\tFound in "..filepath)
                print("\tPrevious was in "..titles[title])
                return nil
            else
                titles[title] = filepath
                titlemap[id] = title
            end
        end
    end

    -- Now we actually generate the posts
    for file in lfs.dir(conf.inputdir) do
        if file ~= "." and file ~= ".." then
            local filepath = conf.inputdir..'/'..file

            -- Read in the file
            f = io.open(filepath, "r")

            -- First line is the # of the post, second is the title, third is date
            local id = tonumber(f:read())
            local title = f:read()
            local date = f:read()
            local content = markdown(f:read("*a"))

            f:close()

            -- Generate the final blog post
            local final = generatepost(conf, templatedata, id, title, date, content, titlemap) 

            -- Save blog post to output directory using only alphanumeric characters
            f = io.open("out/"..titlemap[id])
            f:write(final)
            f:close()

            print ("\t "..filepath)
        end
    end
    return 1
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
if parseposts (config) ~= nil then
    print("[*] Done!")
end
