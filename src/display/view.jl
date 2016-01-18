using Hiccup

typealias AString AbstractString

view(x::AString) = x

view(x) =
  d(:type    => :html,
    :content => stringmime(MIME"text/html"(), x))

view(n::Node) =
  d(:type     => :dom,
    :tag      => tag(n),
    :attrs    => n.attrs,
    :contents => map(view, n.children))

render(::Inline, n::Node; options = d()) = view(n)

render(::Inline, x::HTML; options = d()) = view(x)

function render(::Inline, x::Text; options = d())
  ls = split(string(x), "\n")
  length(ls) > 1 ?
    d(:type => :tree, :head => ls[1], :children => c(join(ls[2:end], "\n"))) :
    ls[1]
end

type Tree
  head
  children::Vector{Any}
end

render(i::Inline, t::Tree; options = d()) =
  d(:type     => :tree,
    :head     => render(i, t.head, options = options),
    :children => map(x->render(i, x, options = options),
                     t.children))

type SubTree
  label
  child
end

render(i::Inline, t::SubTree; options = d()) =
  d(:type  => :subtree,
    :label => render(i, t.label, options = options),
    :child => render(i, t.child, options = options))

# link(x, file) = a(@d("data-file"=>file), x == nothing ? basename(file) : x)
#
# link(x, file, line::Integer) = link(x, "$file:$line")
#
# link(file, line::Integer...) = link(nothing, file, line...)