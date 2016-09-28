Data.streamtypes(::Type{Table}) = [Data.Column, Data.Field]

function (::Type{Data.Schema})(tbl::Table)
    return Data.Schema(
        map(string, fields(tbl)),
        eltypes(tbl),
        nrow(tbl)
    )
end

Data.schema(tbl::Table) = Data.Schema(tbl)

function (::Type{Table})(schema::Data.Schema, ref::Vector{UInt8}=UInt8[])
    new_tbl = Table()
    flds = map(Symbol, Data.header(schema))
    eltypes = map(eltype, Data.types(schema))
    nrows = schema.rows
    if nrows > 0
        for j in 1:length(flds)
            T = eltypes[j]
            new_tbl[flds[j]] = NullableArray{T,1}(
                Vector{T}(nrows),
                fill(true, nrows),
                ref
            )
        end
    else
        for j in 1:length(flds)
            new_tbl[flds[j]] = NullableArray{eltypes[j]}(0)
        end
    end
    return new_tbl
end

function (::Type{Table})(src::CSV.Source)
    res = Table(Data.schema(src), Data.reference(src))
    Data.stream!(src, Data.Field, res, false)
    return res
end

function Data.stream!{T}(source::T, ::Type{Data.Field}, sink::Table, append::Bool=true)
    if Data.types(source) != Data.types(sink)
        msg = "schema mismatch: \n$(Data.schema(source))\nvs.\n$(Data.schema(sink))"
        throw(ArgumentError(msg))
    end
    nrows, ncols = size(source)
    Data.isdone(source, 1, 1) && return sink
    cols = columns(sink)
    types = eltypes(sink)
    if nrows == -1
        sinkrows = size(sink, 1)
        i = 1
        while !Data.isdone(source, i, ncols+1)
            for j = 1:ncols
                Data.pushfield!(source, types[j], cols[j], i, j)
            end
            i += 1
        end
        Data.setrows!(source, sinkrows + i)
    else
        sinkrow = append ? size(sink, 1) - size(source, 1) + 1 : 1
        for i = 1:nrows
            for j = 1:ncols
                Data.getfield!(source, types[j], cols[j], i, j, sinkrow)
            end
            sinkrow += 1
        end
    end
    sink
end

# required for Data.stream! interface
Base.size(tbl::Table) = (nrow(tbl), ncol(tbl))
Base.size(tbl::Table, d) =
    d == 1 ? nrow(tbl) : (d == 2 ? ncol(tbl) : 0)
