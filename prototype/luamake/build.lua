-- Builds:
--  * Every build artifact is defined by an associated build
--  * Builds contain one or more local build variables
--  * Build variables can be defined directly
--  * Build variables can be composed from traits
--  * Build variables can expanded within strings
--  * Build variables can be expanded directly
--  4) Builds are immutable and can be cloned + extended as easily as
--      new_build = existing_build { <definitions> };
--
--  -- A list of traits could be provided to each build
--  b = build(<tool>, <traits>...);
--
--  -- Then, traits would need to be configured
--  b {
--      [trait1] = { ... };
--      [trait2] = { ... };
--  }

function build(form)
    if(type(form) == "string") then
        print("build directory: " .. form);
    else
        print("build form: " .. form.name);
    end
    return function(e) return function() return form end end
end
