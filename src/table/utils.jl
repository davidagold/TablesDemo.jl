replace_dots(field) = searchindex(field, ".") > 0 ? replace(field, ".", "_") : field

# _allowsnulls(A::Array) = false
# _allowsnulls(A::AbstractArray) = true
_hasnulls(A::Array) = false
_hasnulls(A::AbstractArray) = anynull(A)
