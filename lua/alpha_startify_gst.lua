local if_nil = vim.F.if_nil
local startify = require('alpha.themes.startify')
local file_button = startify.file_button

local function git_status_files()
    if not vim.fn.executable("git") then
        return {}
    end
    local handle = io.popen("git status --untracked-files=all --no-renames --short 2> /dev/null")
    local result = handle:read("*a")
    handle:close()
    return vim.tbl_filter(
        function(l) return l ~= "" end,
        vim.split(result, "\n")
    )
end

local function git_status_group(opts)
    opts = if_nil(opts, { max_files = 20 })
    local tbl = {}
    for i, status_line in ipairs(git_status_files()) do
        if i > opts.max_files then
            break
        end

        local parts = vim.split(status_line:gsub("^ +", ""), " +")
        local fname = parts[2]

        tbl[i] = file_button(
            fname,
            string.format("g%d", i - 1),
            status_line,
            false
        )
    end
    return {
        type = "group",
        val = tbl,
        opts = {},
    }
end

local function with_gst(strtfy)
    local layout = strtfy.config.layout
    local section = strtfy.section
    section.gst = {
        type = "group",
        val = {
            { type = "padding", val = 1 },
            { type = "text", val = "GIT STATUS", opts = { hl = "SpecialComment" } },
            { type = "padding", val = 1 },
            {
                type = "group",
                val = function() return { git_status_group() } end,
            },
        },
    }

    local last_padding_idx = 1
    for i, sect in ipairs(layout) do
        if sect and sect.type == "padding" then
            last_padding_idx = i
        end
    end

    table.insert(layout, last_padding_idx, section.gst)

    return strtfy
end

return with_gst(startify)
