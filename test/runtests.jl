using MySQL, ODBC, DBInterface, DataFrames, CSV
using Test
using EzXML, XMLDict
using Base.Iterators
using StatsBase

function clean_line(l)
    c = l[findfirst('(', l):end-1]
    xs = map(x -> x[nextind(x, firstindex(x)):lastindex(x)], split(c, "),"))
    xs[end] = xs[end][1:end-1]
    xs
end

function clean_page_line(l)
    c = l[findfirst('(', l):end-1]
    xs = map(x -> x[2:end], split(c, "NULL),"))
    xs[end] = xs[end][1:end-6]
    xs
end

function pagelinks_line_to_rows(l; re=r"(\d+),(\d+),'(.*)',(\d+)")
    xs = clean_line(l)
    res = match.(re, xs)
    filter!(!isnothing, res)
    map(x -> x.captures, res)
end

function build_df(p3)
    df = DataFrame(from=[], ns=[], title=[], f_ns=[])
    for (i, l) in enumerate(eachline(p3))
        startswith(l, "INSERT INTO") || continue
        rs = l_to_rows(l)
        for row in rs
            push!(df, row)
        end
    end
    df
end

function writelines(ls, fn, header;mode="w")
    open(fn, mode) do f
        !isnothing(header) && println(f, header)
        for l in ls
            println(f, l)
        end
    end
end

takelines(fn, n) = collect(Iterators.take(eachline(fn), n))

function all_lines(fn, dst, clean_f, header)
    open(dst, "w") do io
        println(io,header)
    end
    for l in eachline(fn)
        startswith(l, "INSERT INTO") || continue
        xs = clean_f(l)
        writelines(xs, dst, nothing;mode="a")
    end
end


PAGELINKS_HEADER = "pl_from,pl_namespace,pl_title,pl_from_namespace"
PAGE_HEADER = join(string.(1:12), ",")
datadir = joinpath(@__DIR__, "../data")
fn = "enwiki-20220920-pagelinks.sql"
fn2 = "enwiki-20220920-page.sql"
p, p2 = joinpath.(datadir, [fn, fn2])
dst = joinpath(datadir, "pagelinks.csv")
dst2 =  joinpath(datadir,"page_lines.csv")
all_lines(p, dst, clean_line, PAGELINKS_HEADER)
all_lines(p2, dst2, clean_page_line, PAGE_HEADER)

sql_csv_kws = (escapechar='\\', quotechar=''', silencewarnings=true)
df2 = CSV.read(dst2, DataFrame; sql_csv_kws...)
df2 = df2[df2[:, :2].==0, :]

df = CSV.read(dst, DataFrame; types=Union{String, Missing}, ntasks=1, sql_csv_kws...)



# id_name_map = df[:, [1, 3]]
# CSV.write("id_name_map.csv", id_name_map)
