# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

if __FILE__==$0
	require "fox"
end

def loadImageToString filename
	data=nil
	File.open( filename, "rb"){|f| data=f.read }
	return data.unpack("h#{data.size*2}")[0]
end

def loadImageFromString s, icon_class=Fox::FXPNGIcon
	raise TypeError unless $fxapp
	imgdata= [s].pack( "h#{s.size*2}")
	img=icon_class.new($fxapp, imgdata, Fox::IMAGE_KEEP|Fox::IMAGE_SHMI|Fox::IMAGE_SHMP)
	img.create
	return img
end


def load_dummy
	raise TypeError unless $fxapp
	imgdata="9805e474d0a0a1a0000000d0948444250000000100000001803000000082d2f035000000a247548547342756164796f6e6024596d65600d4f60293026456260223030343021363a33363a3133302b2031303037c63ded4000000704794d454704d2090f0627041559b9c00000090078495370000b0210000b021102ddde7cf000000407614d41400001bf8b0cf16500000003305c44554000000ffefeffff0f0ffc1c1ffcbcbff7878ff5b5bffc5c5ff7979ff9292ffadadff2f2fff7171ff4747ffb4b4ff6e6eff8383bfe98b0d000000104725e43500046e8d66000000b59444144587ad58ec1ee008028040069333b223d7ff7adec6a39c5b57f38d8f406a3992ea61d0508294b382bda9d373840c595953630f0c1c930ece73e940ee8506f8dc0446f14600fddfa260877711b0c50971c4f5ff898f7819b1678020e2a25402a2000000009454e444ea240628"
	imgdata= [imgdata].pack( "h#{imgdata.size*2}")
	$dummy_img=img=Fox::FXPNGIcon.new($fxapp, imgdata, Fox::IMAGE_KEEP|Fox::IMAGE_SHMI|Fox::IMAGE_SHMP)
	img.create
	return img
end
def hasExtension(filename, ext)
	File.basename(filename, ext) != File.basename(filename)
end

# Load the named image file
def loadImage(file)
	img=load_dummy unless $dummy_img

	unless File.exists? file 
		return img
	end
	begin
		opts=Fox::IMAGE_KEEP|Fox::IMAGE_SHMI|Fox::IMAGE_SHMP
		if hasExtension(file, ".gif")
			img = Fox::FXGIFIcon.new($fxapp, nil, opts)
		elsif hasExtension(file, ".bmp")
			img = Fox::FXBMPIcon.new($fxapp, nil, opts)
		elsif hasExtension(file, ".xpm")
			img = Fox::FXXPMIcon.new($fxapp, nil, opts)
		elsif hasExtension(file, ".png")
			img = Fox::FXPNGIcon.new($fxapp, nil, opts)
		elsif hasExtension(file, ".jpg")
			img = Fox::FXJPGIcon.new($fxapp, nil, opts)
		elsif hasExtension(file, ".pcx")
			img = Fox::FXPCXIcon.new($fxapp, nil,opts)
		elsif hasExtension(file, ".tif")
			img = Fox::FXTIFIcon.new($fxapp, nil, opts)
		elsif hasExtension(file, ".tga")
			img = Fox::FXTGAIcon.new($fxapp, nil, opts)
		elsif hasExtension(file, ".ico")
			img = Fox::FXICOIcon.new($fxapp, nil, opts)
		end
		unless img
			puts("Unsupported image type: #{file}")
			return img
		end
		Fox::FXFileStream.open(file, Fox::FXStreamLoad) { |stream| img.loadPixels(stream) }
		img.filename=file
		img.create
	rescue Exception
		puts "load Image: #{$!}"
	end
	img
end

module FX

class Icon
		def initialize filename
			if filename
				@filename=filename
				@img=loadImage(filename)
			end
		end
	attr_accessor :img
	
	def to_s
		@filename
	end
	
		def Icon.LoadFromString s, icon_class=Fox::FXPNGIcon
			icon=Icon.new nil
			icon.img=loadImageFromString s, icon_class
			return icon
		end
		
	end

#color object (united fox functions)
class Color
	attr_accessor :r, :g, :b, :a
	#construct by red, green, blue and (optionally) alpha value
	def initialize r=0, g=0, b=0, a=nil
		@r,@g,@b,@a=r,g,b,a
	end
	#returns Fox::FXColor value
	def to_FXColor
		@a ? Fox::FXRGBA(@r,@g,@b,@a) : Fox::FXRGB(@r,@g,@b)
	end
	#get value from FXColor
	def from_FXColor c
		@r=Fox::FXREDVAL(c)
		@g=Fox::FXGREENVAL(c)
		@b=Fox::FXBLUEVAL(c)
		@a=Fox::FXALPHAVAL(c)
		self
	end
	#get value according to Fox colorname
	def from_name( name)
		from_FXColor( Fox::fxcolorfromname( name))
		self
	end
	#encode binary string representation
	def serialize
		Fox::fxencodeColorData(to_FXColor)
	end
	#decode from binary string representation
	def deserialize(data)
		from_FXColor( Fox::fxdecodeColorData(data))
		self
	end
	#returns human readable string representation
	def to_s
		(@a ? [@r,@g,@b,@a] : [@r,@g,@b]).join(',')
	end
	#reads value from human readable string representation
	def from_s s
		s= "0, 0, 0, 0" if s.size<5
		@r,@g,@b,@a=s.split(',').collect{|c| c.to_i}
		self
	end
	end
	#font object. cannot be substituted for FXFont
	class Font
		#param is either a Fox::FXFontDesc or a string representation
		def initialize
			@fd=Fox::FXFontDesc.new
		end
		attr_accessor :fd
		#human readable string representation
		def to_s
			@fd.to_s
		end
		def from_s s
			@fd.from_s s
			self
		end
		def to_FXFont
			f=Fox::FXFont.new $fxapp, @fd
			f.create
			f
		end
		def from_FXFont f
			@fd=f.fontDesc
			self
		end
	end
end # module

class Fox::FXIcon
	attr_accessor :filename
	def to_s
		filename ? filename : ''
	end
end


class Fox::FXFontDesc
	#~ alias :_initialize_ :initialize 
	#~ def initialize
		#~ _initialize_ 
		#~ from_s "Tahoma|80|400|1|0|0|0"
	#~ end
	#human readable string representation
	def to_s
		[self.face, 
		self.size, 
		self.weight, 
		self.slant, 
		self.encoding, 
		self.setwidth, 
		self.flags].join( '|')
	end
	#parse human readable string representation
	def from_s( s )
		#~ begin
			a=s.split('|')
			self.face=a[0] 
			self.size=a[1].to_i
			self.weight=a[2].to_i
			self.slant=a[3].to_i
			self.encoding=a[4].to_i
			self.setwidth=a[5].to_i
			self.flags=a[6].to_i
		#~ rescue Exception
			#~ puts "error parsing string representation: #{$!}"
			#~ puts $!.backtrace.join($/)
			#~ return nil
		#~ end
		self
	end
	#initialize from other font desc or string representation
	def init fd
		if fd.kind_of? Fox::FXFontDesc
			self.face=fd.face
			self.size=fd.size
			self.weight=fd.weight
			self.slant=fd.slant
			self.encoding=fd.encoding
			self.setwidth=fd.setwidth
			self.flags=fd.flags
		elsif fd.kind_of? String
			from_s fd
		end
	end
end
class Fox::FXFont
	def to_s
		fontDesc.to_s
	end
end
class Fox::FXIcon
	attr_accessor :filename
	def to_s
		filename ? filename : ''
	end
end

if __FILE__==$0
	s=loadImageToString "icon_not_found.png"
	puts s=="9805e474d0a0a1a0000000d0948444250000000100000001803000000082d2f035000000a247548547342756164796f6e6024596d65600d4f60293026456260223030343021363a33363a3133302b2031303037c63ded4000000704794d454704d2090f0627041559b9c00000090078495370000b0210000b021102ddde7cf000000407614d41400001bf8b0cf16500000003305c44554000000ffefeffff0f0ffc1c1ffcbcbff7878ff5b5bffc5c5ff7979ff9292ffadadff2f2fff7171ff4747ffb4b4ff6e6eff8383bfe98b0d000000104725e43500046e8d66000000b59444144587ad58ec1ee008028040069333b223d7ff7adec6a39c5b57f38d8f406a3992ea61d0508294b382bda9d373840c595953630f0c1c930ece73e940ee8506f8dc0446f14600fddfa260877711b0c50971c4f5ff898f7819b1678020e2a25402a2000000009454e444ea240628"
end
