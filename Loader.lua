-- ---------------------------------------------------------------------------
-- Steal a Superpower Hub - always-latest loader
-- Repository: https://github.com/reizure87-create/StealASuperpower
-- Build: 2026-11-08
--
-- Usage (PC and mobile executors):
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/reizure87-create/StealASuperpower/main/Loader.lua"))()
--
-- This loader downloads the current StealASuperpower.lua and runs it. The main
-- script checks the universe ID before doing anything, so it is safe to use
-- this loader in other games.
-- ---------------------------------------------------------------------------

local REPO_RAW = "https://raw.githubusercontent.com/reizure87-create/StealASuperpower/main"
local SCRIPT_URL = REPO_RAW .. "/StealASuperpower.lua"
local MIN_SOURCE_LENGTH = 2000

local function notifyError(message)
    message = "[SAS Loader] " .. tostring(message)
    warn(message)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "SAS Loader",
            Text = tostring(message),
            Duration = 6,
        })
    end)
end

local function httpGet(url)
    local requestFn = (syn and syn.request)
        or (http and http.request)
        or http_request
        or request
    if requestFn then
        local ok, response = pcall(requestFn, {
            Url = url,
            Method = "GET",
        })
        if ok and type(response) == "table" and type(response.Body) == "string" and #response.Body > 0 then
            return response.Body
        end
    end

    local ok, body = pcall(function()
        return game:HttpGet(url, true)
    end)
    if ok and type(body) == "string" and #body > 0 then
        return body
    end
    return nil
end

local source = httpGet(SCRIPT_URL .. "?t=" .. tostring(os.time()))
if not source or #source < MIN_SOURCE_LENGTH then
    notifyError("Could not download the script. Check your connection and try again.")
    return
end

if source:find("<html", 1, true) or source:find("404: Not Found", 1, true) then
    notifyError("The download returned an error page instead of Lua source.")
    return
end

local chunk, loadError
if loadstring then
    chunk, loadError = loadstring(source, "StealASuperpower")
else
    chunk, loadError = load(source, "StealASuperpower")
end
if not chunk then
    notifyError("Downloaded source did not compile: " .. tostring(loadError))
    return
end

local ok, runError = pcall(chunk)
if not ok then
    notifyError("Script error: " .. tostring(runError))
    return
end

print("[SAS Loader] Steal a Superpower Hub loaded from the repository.")
