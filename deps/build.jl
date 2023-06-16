using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()
using libusb_jll
using Clang.Generators

header = joinpath(libusb_jll.artifact_dir, "include/libusb-1.0/libusb.h")
cd(@__DIR__)
options = load_options("generator.toml")
args = get_default_args()
push!(args, "-I$(dirname(header))")
ctx = create_context([header,], args, options)
build!(ctx)
