require("luci.sys")

m = Map("helloserver", translate("HelloServer"), translate("Configuration HelloServer"))

sr = m:section(TypedSection, "server", "Paramétrage du serveur")
sr.addremove = false
sr.anonymous = false

identifiant        = sr:option(Value, "message",        translate("Message à afficher devant 'World'"))
identifiant.maxlength = 12
function identifiant:validate(value)
        return value:match("^[0-9A-Za-z\-_ ]+$") 
end

local apply = luci.http.formvalue("cbi.apply")
if apply then
        io.popen("/etc/init.d/helloserver restart")
end

return m
