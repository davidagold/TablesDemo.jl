"""
    `getindex(tbl::Table, fld::Symbol)`

Extract the column with field `fld` from `tbl`. Equivalent to `tbl[fld]`
"""
Base.getindex(tbl::Table, fld::Symbol) = columns(tbl)[index(tbl)[fld]]

"""
    `setindex(tbl::Table, col, fld::Symbol)`

Set `col` as the column respective to `fld` in `tbl`. Equivalent to
`tbl[fld] = col`

Notes: `col` will not be coerced. `length(col)` must equal `nrow(tbl)`.
"""
function Base.setindex!(tbl::Table, col::AbstractArray, field::Symbol)
    field = Symbol(replace_dots(string(field)))
    nrows, ncols = nrow(tbl), ncol(tbl)
    if (ncols > 0) & (length(col) != nrows)
        msg = "All columns in a Table must be the same length"
        throw(ArgumentError(msg))
    end
    j = get!(()->ncols+1, index(tbl), field)
    cols = columns(tbl)
    flds = fields(tbl)
    if j <= ncols
        cols[j] = convert(NullableArray, col)
        # tbl.allowsnulls[j] = _allowsnulls(col)
        tbl.hasnulls[j] = _hasnulls(col)
    else
        push!(cols, convert(NullableArray, col))
        push!(flds, field)
        # push!(tbl.allowsnulls, _allowsnulls(col))
        push!(tbl.hasnulls, _hasnulls(col))
    end
    return col
end
