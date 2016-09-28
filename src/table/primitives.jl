# AbstractTable interface

"""
    `fields(tbl::Table)`

Obtain an ordered list of fields (column names) of `tbl`.

Notes: `fields(tbl)` is dual to `index(tbl)` in the sense that

fields(tbl)[(index(tbl)[fld]] == fld
index(tbl)[(fields(tbl)[i]] == i
"""
AbstractTables.fields(tbl::Table) = tbl.fields

AbstractTables.eltypes(tbl::Table) = map(eltype, columns(tbl))
AbstractTables.eltypes(tbl::Table, fields::Symbol...) =
    map(eltype, [ tbl[field] for field in fields ])

"""
    `nrow(tbl::Table)`

Obtain the number of rows contained in `tbl`.
"""
AbstractTables.nrow(tbl::Table) = ncol(tbl) > 0 ? length(tbl.columns[1]) : 0

# Column indexable interface

"""
    `columns(tbl::Table)`

Obtain the columns of `tbl`.
"""
AbstractTables.columns(tbl::Table) = tbl.columns

"""
    `index(tbl::Table)`

Obtain the index of `tbl`.
"""
AbstractTables.index(tbl::Table) = tbl.index

# Other

"""
    `copy(tbl)`

Return a copy of `tbl`.

Notes: applies `copy` to each column and inserts the copies into an `empty`
`Table`.
"""
function Base.copy(tbl::Table)
    new_tbl = Table()
    for (fld, col) in eachcol(tbl)
        new_tbl[fld] = copy(col)
    end
    return new_tbl
end

function Base.isequal(tbl1::Table, tbl2::Table)
    isequal(ncol(tbl1), ncol(tbl2)) || return false
    # isequal(tbl1.allowsnulls, tbl2.allowsnulls) || return false
    isequal(tbl1.hasnulls, tbl2.hasnulls) || return false
    for ((fld1, col1), (fld2, col2)) in zip(eachcol(tbl1), eachcol(tbl2))
        isequal(fld1, fld2) || return false
        isequal(col1, col2) || return false
    end
    return true
end

function Base.hash(tbl::Table)
    # h = hash(tbl.allowsnulls) + 1
    h = hash(tbl.hasnulls) + 1
    for (i, (fld, col)) in enumerate(eachcol(tbl))
        h = hash(i, h)
        h = hash(fld, h)
        h = hash(tbl[fld], h)
    end
    return @compat UInt(h)
end
