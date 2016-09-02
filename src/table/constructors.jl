"""
    Table([kwargs...])

`Table`s can be initialized with field-column pairs by passing the latter as
keyword arguments.

Examples:

* `Table(a = [1, 2], b = [3, 4])`
* `Table(ID = collect(1:10))`

Notes: Columns are not coerced upon `Table` initialization.
"""
function (::Type{Table})(; kwargs...)
    res = Table(Dict{Symbol,Int}(), [])
    for (k, v) in kwargs
        res[k] = v
    end
    return res
end
