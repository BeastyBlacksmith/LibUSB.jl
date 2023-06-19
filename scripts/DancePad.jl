using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using LibUSB

VID = 0x0079 #0x18F8 mouse # 0079 dance pad
PID = 0x0011 #0x0F99 mouse # 0011 dance pad

handle = LibUSB.Low.libusb_open_device_with_vid_pid(LibUSB.LIBUSB_CONTEXT[], VID, PID)
if !LibUSB.is_null(handle)
    LibUSB.Low.libusb_set_auto_detach_kernel_driver(handle, 1)
    ret = LibUSB.Low.libusb_claim_interface(handle, 0)
    # dev = LibUSB.Low.libusb_get_device(handle)
    # config = Ref{Ptr{LibUSB.Low.libusb_config_descriptor}}()
    # ret = LibUSB.Low.libusb_get_active_config_descriptor(dev, config)
    # endpoint = unsafe_load(unsafe_load(unsafe_load(unsafe_load(config[]).interface).altsetting).endpoint)
    # @show endpoint_address = endpoint.bEndpointAddress
    # @show packet_size = endpoint.wMaxPacketSize
    endpoint_address = 0x81
    buffer = Vector{UInt8}(undef, 8)
    debounce_time = 30
    actual_length = Ref(Cint(0))
    # LibUSB.Low.libusb_free_config_descriptor(config[])
    try
        while true
            ret = LibUSB.Low.libusb_interrupt_transfer(handle, endpoint_address, buffer, length(buffer), actual_length, debounce_time)
            @show ret
            @show actual_length[]
            @show buffer
            if ret == LibUSB.Low.LIBUSB_SUCCESS && actual_length[] > 0
                println(String(buffer))
            end
            sleep(0.1)
        end
    finally
        LibUSB.Low.libusb_release_interface(handle, 0)
        LibUSB.Low.libusb_close(handle)
    end
else
    LibUSB.Low.libusb_close(handle)
end

