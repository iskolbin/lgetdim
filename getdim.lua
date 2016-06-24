local function u16( f, littleendian )
	local a, b = f:read(2):byte(1, 2)
	if littleendian then	
		return b*(2^8) + a
	else
		return a*(2^8) + b
	end
end

local function u32( f, littleendian )
	local a, b, c, d = f:read(4):byte(1, 4)
	if littleendian then
		return d*(2^24) + c*(2^16) + b*(2^8) + a
	else
		return a*(2^24) + b*(2^16) + c*(2^8) + d
	end
end

local JPEG_MARKERS_1 = {
	[0xffd8] = true, -- SOI
	[0xffd0] = true, -- RST0
	[0xffd1] = true, -- RST1
	[0xffd2] = true, -- RST2
	[0xffd3] = true, -- RST3
	[0xffd4] = true, -- RST4
	[0xffd5] = true, -- RST5
	[0xffd6] = true, -- RST6
	[0xffd7] = true, -- RST7
	[0xffd9] = true, -- EOI
}

local JPEG_MARKERS_2 = {
	[0xffe0] = true, -- APP0
	[0xffe1] = true, -- APP1
	[0xffe2] = true, -- APP2
	[0xffe3] = true, -- APP3
	[0xffe4] = true, -- APP4
	[0xffe5] = true, -- APP5
	[0xffe6] = true, -- APP6
	[0xffe7] = true, -- APP7
	[0xffe8] = true, -- APP8
	[0xffe9] = true, -- APP9
	[0xffea] = true, -- APPa
	[0xffeb] = true, -- APPb
	[0xffec] = true, -- APPc
	[0xffed] = true, -- APPd
	[0xffee] = true, -- APPe
	[0xffef] = true, -- APPf
	[0xfffe] = true, -- COM
	[0xffdb] = true, -- DQT
	[0xffc4] = true, -- DHT
	[0xffda] = true, -- SOS
}

local function getdim( path )
	local f, err = io.open( path )
	if err then
		return nil, nil, nil, 'Cannot open file: ' .. tostring(path)
	else
		local header = u16( f )
		if header == 0x8950 then
			f:read( 14 )
			return u32( f ), u32( f ), 'PNG'
		
		elseif header == 0x424D then
			f:read( 16 )
			return u32( f, 'little' ), u32( f, 'little' ), 'BMP'
		
		elseif header == 0x4749 then
			f:read( 4 )
			return u16( f, 'little' ), u16( f, 'little' ), 'GIF'
		
		elseif header == 0xFFD8 then
			while true do
				local marker = u16( f )
				if JPEG_MARKERS_1[marker] then
				
				elseif marker == 0xffdd then -- DRI
					u16( f )

				elseif JPEG_MARKERS_2[marker] then
					f:read( u16( f ) - 2 )

				elseif marker == 0xffc0 or marker == 0xffc2 then -- SOF0 or SOF2
					f:read( 3 )
					local h, w = u16( f ), u16( f )
					return w, h, 'JPG'

				else
					return nil, nil, 'JPG', 'Invalid jpeg marker: ' .. ('0x%x'):format(marker)
				end	
			end	
		else
			return nil, nil, nil, 'Illegal header: ' .. ('0x%x'):format(header)
		end
	end
end

local function collect( format, w, h, t, path )
	local result = format:gsub( '$(%w+)', { 
		w = w,
		h = h,
		t = t:lower(),
		p = path:lower(),
		T = t:upper(),
		P = t:upper(),
		tab = '\t',
		newline = '\n',
	}):gsub( '$$', '$' )
	return result
end

local function cli( path, format )
	if not path and not format then
		print( [[
getdim
======
Lua script to get image dimensions. Usage: 
	assume we have 10x10 png named img.png, next script prints in console 
	width and height of image, separated by tabulation: 10	10

lua getdim.lua img.png [format]

Using formatting. For example executing

lua getdim.lua img.png '$p$tab$w$tab$h$newline'

prints in console: img.png	10	10

Available format options:
	* **$w** -- width
	* **$h** -- height
	* **$t** -- type
	* **$T** -- uppercased type
	* **$p** -- path
	* **$P** -- uppercased type
	* **$$** -- dollar sign
	* **$tab** -- tabulation
	* **$newline** -- newline
	
Coded by Ilya Kolbin (iskolbin@gmail.com), 
original code http://www.java-gaming.org/index.php?topic=21438.0]] )
		return 
	end

	local w, h, t, err = getdim( path )
	if err then
		io.write( err )
	else
		format = format or '$w$tab$h$newline'
		io.write( collect( format, w, h, t, path ))
	end
end

if arg then
	cli(( table.unpack or unpack )( arg ))
end

return getdim
