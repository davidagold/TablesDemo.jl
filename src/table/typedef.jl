"""
A tabular data type.

Fields:

* `index::Dict{Symbol, Int}`: A mapping from symbols to numeric column indices
* `columns::Vector{NullableVector}`: A vector of NullableVector columns
* `fields::Vector{Symbol}`: A vector of fields (column names)
<!-- * `allowsnulls::Vector{Bool}`: A vector of flags indicating whether the
respective column allows storage of null values -->
* `hasnulls::Vector{Bool}`: A vector of flags indicating whether the
respective column currently stores any null values

Notes: The ordering of the columns in `columns` respects that of the numeric
indices given by `index`.

<!-- If `allowsnulls[i] == false` then `hasnulls[i]` must also `== false`.

Columns are assumed to be either `Array` or `NullableArray` objects. If
`isa(columns[i], Array)` then `allowsnulls[i] == false`. -->

The types of columns are not coerced upon `Table` initialization.

`'.'` is not a valid character within a field. All instances of `'.'` will be
replaced by `'_'` upon constructing a `Table` or setting a column.
"""
type Table <: AbstractTables.AbstractTable
    index::Dict{Symbol, Int}
    columns::Vector{NullableVector}
    fields::Vector{Symbol}
    # allowsnulls::Vector{Bool}
    hasnulls::Vector{Bool}
    metadata::Dict{Symbol, Any}

    function Table(index, columns)
        ncols = length(columns)
        # allowsnulls = Vector{Bool}(ncols)
        hasnulls = Vector{Bool}(ncols)
        if ncols > 1
            nrows = length(columns[1])
            equallengths = true
            for (j, col) in enumerate(columns)
                equallengths &= length(col) == nrows
                # allowsnulls[j] = _allowsnulls(col)
                hasnulls[j] = _hasnulls(col)
            end
            if !equallengths
                msg = "All columns in a Table must be the same length"
                throw(ArgumentError(msg))
            end
        end
        fields = Array{Symbol}(ncols)
        for key in keys(index)
            key = Symbol(replace_dots(string(key)))
            fields[index[key]] = key
        end
        length(index) == length(columns) || error()
        new(index, columns, fields, hasnulls, Dict{Symbol, Any}())
    end
end
