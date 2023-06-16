using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using LibUSB

VID = 0x0079 #0x18F8 mouse # 0079 dance pad
PID = 0x0011 #0x0F99 mouse # 0011 dance pad

handle = LibUSB.Low.libusb_open_device_with_vid_pid(LibUSB.LIBUSB_CONTEXT[], VID, PID)
LibUSB.Low.libusb_set_auto_detach_kernel_driver(handle, 1)
ret = LibUSB.Low.libusb_claim_interface(handle, 0)
dev = LibUSB.Low.libusb_get_device(handle)
config = Ref{Ptr{LibUSB.Low.libusb_config_descriptor}}()
ret = LibUSB.Low.libusb_get_active_config_descriptor(dev, config)
endpoint = unsafe_load(unsafe_load(unsafe_load(unsafe_load(config[]).interface).altsetting).endpoint)
endpoint_address = endpoint.bEndpointAddress
packet_size = endpoint.wMaxPacketSize
