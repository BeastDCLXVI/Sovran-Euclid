# ═══════════════════════════════════════════════════════════════════
# Sovran.jl — UFT · UAFT · Sovran foundation umbrella
# Author: Mateusz Faber-Suckert
# MIT License · API-free · Load order for the whole field stack.
#
#   include("Sovran.jl"); using .Sovran
#
# Brings up, in dependency order:
#   UFTField → UAFTField → CarbonCode → SovranQubit → AnalogAGI
# ═══════════════════════════════════════════════════════════════════
module Sovran

include("UFTField.jl")
include("UAFTField.jl")
include("CarbonCode.jl")
include("SovranQubit.jl")
include("AnalogAGI.jl")

using .UFTField, .UAFTField, .CarbonCode, .SovranQubit, .AnalogAGI

# re-export the public surface
for m in (:UFTField, :UAFTField, :CarbonCode, :SovranQubit, :AnalogAGI)
    @eval export $m
end

end # module Sovran
