module Tables

using Reexport
using Compat
@reexport using AbstractTables
@reexport using DataStreams
@reexport using CSV
# @reexport using NullableArrays

export  Table

# Table
include("table/utils.jl")
include("table/typedef.jl")
include("table/traits.jl")
include("table/constructors.jl")
include("table/primitives.jl")
include("table/indexing.jl")
include("table/io.jl")

# query
include("query/interface.jl")

end # module Tables
