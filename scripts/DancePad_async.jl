using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using LibUSB

VID = 0x0079 #0x18F8 mouse # 0079 dance pad
PID = 0x0011 #0x0F99 mouse # 0011 dance pad

function transfer_callback(trans)
    @show trans[].status
    @show trans[].actual_length
    @show trans[].buffer
    LibUSB.Low.libusb_submit_transfer(trans)
end
handle = LibUSB.Low.libusb_open_device_with_vid_pid(LibUSB.LIBUSB_CONTEXT[], VID, PID)
if !LibUSB.is_null(handle)
    LibUSB.Low.libusb_set_auto_detach_kernel_driver(handle, 1)
    ret = LibUSB.Low.libusb_claim_interface(handle, 0)
    endpoint_address = 0x81
    buffer = Vector{UInt8}(undef, 8)
    debounce_time = 30
    actual_length = Ref(Cint(0))
    trans = LibUSB.Low.libusb_alloc_transfer(0)
    LibUSB.Low.libusb_fill_bulk_transfer(trans, handle, endpoint_address, buffer, length(buffer), @cfunction(transfer_callback, Cint, (Ptr{LibUSB.Low.libusb_transfer},)), C_NULL, 0)
    LibUSB.Low.libusb_submit_transfer(trans)
    try
        while true
            LibUSB.Low.libusb_handle_events(LibUSB.LIBUSB_CONTEXT[])
        end
    finally
        LibUSB.Low.libusb_free_transfer(trans)
        LibUSB.Low.libusb_release_interface(handle, 0)
        LibUSB.Low.libusb_close(handle)
    end
else
    LibUSB.Low.libusb_close(handle)
end

