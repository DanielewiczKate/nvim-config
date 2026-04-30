-- Ensure the semicolon is treated as part of the word

local function smart_abbr(prefix, root, suffix, result_root)
    -- 1. Create the Lowercase Version
    local lhs_low = prefix .. root .. suffix 
    local rhs_low = result_root
    vim.cmd(string.format("iabbrev %s %s", lhs_low, rhs_low))

    -- 2. Create the Capitalized Version
    -- Uppercase the first letter of the root only
    local root_cap = root:gsub("^%l", string.upper)
    -- Uppercase the first letter of the result word
    local result_cap = result_root:gsub("^%l", string.upper)
    
    local lhs_cap = prefix .. root_cap .. suffix 
    vim.cmd(string.format("iabbrev %s %s", lhs_cap, result_cap))
end

-- USAGE EXAMPLES:
smart_abbr("cd", "ab", "", "smart_abbr(\"\", \"\", \"\", \"\")")
-- =============================================================================
-- COMMON WORD ABBREVIATIONS (Prefix: ee)
-- =============================================================================

-- 1. CONNECTIVES & ADVERBS
local c_lib = "e"
smart_abbr(c_lib, "b", "",    "because")
smart_abbr(c_lib, "s", "",    "should")
smart_abbr(c_lib, "w", "",    "would")
smart_abbr(c_lib, "e", "",    "example")
smart_abbr(c_lib, "e", "s",   "examples")
smart_abbr(c_lib, "t", "u",   "through")
smart_abbr(c_lib, "v", "",    "between")
smart_abbr(c_lib, "f", "",    "fail")
smart_abbr(c_lib, "f", "d",   "failed")
smart_abbr(c_lib, "f", "n",   "failuire")
smart_abbr(c_lib, "c", "",    "sucssess")
smart_abbr(c_lib, "c", "d",    "succeeded")

-- =============================================================================
-- ELECTRICAL ABBREVIATIONS
-- =============================================================================

-- 1. THE ORIGINALS & CORE PASSIVES
-- Components (root), Properties (a), Plurals (s), Plural Properties (as)

local e_lib = "l"
smart_abbr(e_lib, "ca", "",   "capacitor")
smart_abbr(e_lib, "ca", "a",  "capacitance")
smart_abbr(e_lib, "ca", "s",  "capacitors")
smart_abbr(e_lib, "ca", "as", "capacitances")

smart_abbr(e_lib, "in", "",   "inductor")
smart_abbr(e_lib, "in", "a",  "inductance")
smart_abbr(e_lib, "in", "s",  "inductors")
smart_abbr(e_lib, "in", "as", "inductances")

smart_abbr(e_lib, "re", "",   "resistor")
smart_abbr(e_lib, "re", "a",  "resistance")
smart_abbr(e_lib, "re", "s",  "resistors")
smart_abbr(e_lib, "re", "as", "resistances")

-- 2. POWER & NETWORK ANALYSIS
smart_abbr(e_lib, "im", "",   "impedance")
smart_abbr(e_lib, "im", "s",  "impedances")
-- Impedance/Admittance usually serve as both the noun and property
smart_abbr(e_lib, "ad", "",   "admittance")
smart_abbr(e_lib, "ad", "s",  "admittances")

smart_abbr(e_lib, "vo", "",   "voltage")
smart_abbr(e_lib, "vo", "s",  "voltages")

smart_abbr(e_lib, "cu", "",   "current")
smart_abbr(e_lib, "cu", "s",  "currents")

smart_abbr(e_lib, "co", "",   "conductor")
smart_abbr(e_lib, "co", "a",  "conductance")
smart_abbr(e_lib, "co", "s",  "conductors")
smart_abbr(e_lib, "co", "as", "conductances")

-- 3. SEMICONDUCTORS & ACTIVE COMPONENTS
smart_abbr(e_lib, "tr", "",   "transistor")
smart_abbr(e_lib, "tr", "s",  "transistors")

smart_abbr(e_lib, "di", "",   "diode")
smart_abbr(e_lib, "di", "s",  "diodes")

smart_abbr(e_lib, "ga", "",   "gain")
smart_abbr(e_lib, "ga", "s",  "gains")

smart_abbr(e_lib, "ph", "",   "phase")
smart_abbr(e_lib, "ph", "s",  "phases")

-- 4. PHYSICAL PROPERTIES & BEHAVIOR
-- Corrected "paracitic" to "parasitic"
smart_abbr(e_lib, "pa", "",   "parasitic")
smart_abbr(e_lib, "pa", "s",  "parasitics")

smart_abbr(e_lib, "ef", "",   "efficient")
smart_abbr(e_lib, "ef", "a",  "efficiency")
smart_abbr(e_lib, "ef", "as", "efficiencies")

smart_abbr(e_lib, "th", "",   "thermal")
smart_abbr(e_lib, "th", "a",  "threshold")
smart_abbr(e_lib, "th", "as", "thresholds")

smart_abbr(e_lib, "ma", "",   "magnetic")
smart_abbr(e_lib, "ma", "a",  "magnetism")

smart_abbr(e_lib, "rs", "",   "resonance")
smart_abbr(e_lib, "rs", "a",  "resonant")

-- 5. SPECIAL SYMBOLS & HELPERS
vim.cmd([[iabbrev So Ω]])    -- Ohm
vim.cmd([[iabbrev Sm µ]])    -- Micro
vim.cmd([[iabbrev Sd °]])    -- Degree
vim.cmd([[iabbrev Spm ±]])   -- Plus-Minus

-- Brackets with cursor positioning
vim.cmd([[iabbrev Scb {}<Left>]])
vim.cmd([[iabbrev Sb ()<Left>]])
vim.cmd([[iabbrev SB []<Left>]])
