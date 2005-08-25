#! /usr/local/bin/ruby -w

require 'RMagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'fileutils'

# TODO: fill in test_statistics for GraphicsMagick

ColorspaceTypes = [
  Magick::RGBColorspace,
  Magick::GRAYColorspace,
  Magick::TransparentColorspace,
  Magick::OHTAColorspace,
# Magick::LABColorspace,
  Magick::XYZColorspace,
  Magick::YCbCrColorspace,
  Magick::YCCColorspace,
  Magick::YIQColorspace,
  Magick::YPbPrColorspace,
  Magick::YUVColorspace,
  Magick::CMYKColorspace,
  Magick::SRGBColorspace,
  Magick::HSBColorspace,
  Magick::HSLColorspace,
  Magick::HWBColorspace,
# Magick::Rec601LumaColorspace,
# Magick::Recc709LumaColorspace,
# LogColorspace
]

class Image3_UT < Test::Unit::TestCase
    
    def setup
        @img = Magick::Image.new(20, 20)
    end
    
    def test_profile!
    	assert_nothing_raised do
    		res = @img.profile!('*', nil)
    		assert_same(@img, res)
    	end
    	assert_nothing_raised { @img.profile!('icc', 'xxx') }
    	assert_nothing_raised { @img.profile!('iptc', 'xxx') }
    	assert_nothing_raised { @img.profile!('icc', nil) }
    	assert_nothing_raised { @img.profile!('iptc', nil) }
    	
    	@img.freeze
    	assert_raise(TypeError) { @img.profile!('icc', 'xxx') }
    	assert_raise(TypeError) { @img.profile!('*', nil) }
    end
    
    def test_quantize
    	assert_nothing_raised do 
    		res = @img.quantize
    		assert_instance_of(Magick::Image, res)
    	end
    			  
		ColorspaceTypes.each do |cs|
			assert_nothing_raised { @img.quantize(256, cs) }
		end
		assert_nothing_raised { @img.quantize(256, Magick::RGBColorspace, false) }
		assert_nothing_raised { @img.quantize(256, Magick::RGBColorspace, true, 2) }
		assert_nothing_raised { @img.quantize(256, Magick::RGBColorspace, true, 2, true) }
		assert_raise(TypeError) { @img.quantize('x') }
		assert_raise(TypeError) { @img.quantize(16, 2) }
		assert_raise(TypeError) { @img.quantize(16, Magick::RGBColorspace, false, 'x') }
	end

	def test_quantum_operator
		quantum_ops = [
			Magick::AddQuantumOperator,
			Magick::AndQuantumOperator,
			Magick::DivideQuantumOperator,
			Magick::LShiftQuantumOperator,
			Magick::MultiplyQuantumOperator,
			Magick::OrQuantumOperator,
			Magick::RShiftQuantumOperator,
			Magick::SubtractQuantumOperator,
			Magick::XorQuantumOperator ]
		
		assert_nothing_raised do
    		res = @img.quantum_operator(Magick::AddQuantumOperator, 2)
    		assert_instance_of(Magick::Image, res)
    	end
    	quantum_ops.each do |op|
    		assert_nothing_raised { @img.quantum_operator(op, 2) }
    	end
    	assert_nothing_raised { @img.quantum_operator(Magick::AddQuantumOperator, 2, Magick::RedChannel) }
    	assert_raise(TypeError) { @img.quantum_operator(2, 2) }
    	assert_raise(TypeError) { @img.quantum_operator(Magick::AddQuantumOperator, 'x') }
    	assert_raise(TypeError) { @img.quantum_operator(Magick::AddQuantumOperator, 2, 2) }
    	assert_raise(ArgumentError) { @img.quantum_operator(Magick::AddQuantumOperator, 2, Magick::RedChannel, 2) }
    end
    
    def test_radial_blur
    	assert_nothing_raised do
    		res = @img.radial_blur(30)
    		assert_instance_of(Magick::Image, res)
    	end
    end
    
    def test_raise
    	assert_nothing_raised do
    		res = @img.raise
    		assert_instance_of(Magick::Image, res)
    	end
    	assert_nothing_raised { @img.raise(4) }
    	assert_nothing_raised { @img.raise(4,4) }
    	assert_nothing_raised { @img.raise(4,4, false) }
    	assert_raise(TypeError) { @img.raise('x') }
    	assert_raise(TypeError) { @img.raise(2, 'x') }
    	assert_raise(ArgumentError) { @img.raise(4, 4, false, 2) }
    end
    
    def test_random_threshold_channel
    	assert_nothing_raised do
    		res = @img.random_threshold_channel('20%')
    		assert_instance_of(Magick::Image, res)
    	end
    	threshold = Magick::Geometry.new(20)
    	assert_nothing_raised { @img.random_threshold_channel(threshold) }
    	assert_nothing_raised { @img.random_threshold_channel(threshold, Magick::RedChannel) }
    	assert_nothing_raised { @img.random_threshold_channel(threshold, Magick::RedChannel, Magick::BlueChannel) }
  		assert_raise(ArgumentError) { @img.random_threshold_channel }
  		assert_raise(TypeError) { @img.random_threshold_channel('20%', 2) }
  	end
  	
  	def test_reduce_noise
  		assert_nothing_raised do
  			res = @img.reduce_noise(0)
  			assert_instance_of(Magick::Image, res)
  		end
  		assert_nothing_raised { @img.reduce_noise(4) }
  	end
  	
  	def test_resize
  		assert_nothing_raised do
  			res = @img.resize(2)
  			assert_instance_of(Magick::Image, res)
  		end
  		assert_nothing_raised { @img.resize(50,50) }
  		filters = [
  		  Magick::PointFilter, 
		  Magick::BoxFilter,
		  Magick::TriangleFilter,
		  Magick::HermiteFilter,
		  Magick::HanningFilter,
		  Magick::HammingFilter,
		  Magick::BlackmanFilter,
		  Magick::GaussianFilter,
		  Magick::QuadraticFilter,
		  Magick::CubicFilter,
		  Magick::CatromFilter,
		  Magick::MitchellFilter,
		  Magick::LanczosFilter,
		  Magick::BesselFilter,
		  Magick::SincFilter ]
		  
		filters.each do |filter|
			assert_nothing_raised { @img.resize(50, 50, filter) }
		end
		assert_nothing_raised { @img.resize(50, 50, Magick::PointFilter, 2.0) }
		assert_raise(TypeError) { @img.resize('x') }
		assert_raise(TypeError) { @img.resize(50, 'x') }
		assert_raise(TypeError) { @img.resize(50, 50, 2) }
		assert_raise(TypeError) { @img.resize(50, 50, Magick::CubicFilter, 'x') }
		assert_raise(ArgumentError) { @img.resize(50, 50, Magick::SincFilter, 2.0, 'x') }
		assert_raise(ArgumentError) { @img.resize }
	end
	
	def test_resize!
		assert_nothing_raised do
			res = @img.resize!(2)
			assert_same(@img, res)
		end
		@img.freeze
		assert_raise(TypeError) { @img.resize!(0.50) }
	end
			
	def test_roll
		assert_nothing_raised do
			res = @img.roll(5, 5)
			assert_instance_of(Magick::Image, res)
		end
	end
	
	def test_rotate
		assert_nothing_raised do
			res = @img.rotate(45)
			assert_instance_of(Magick::Image, res)
		end
		assert_nothing_raised { @img.rotate(-45) }
	end
	
	def test_rotate!
		assert_nothing_raised do
			res = @img.rotate!(45)
			assert_same(@img, res)
		end
		@img.freeze
		assert_raise(TypeError) { @img.rotate!(45) }
	end
	
	def test_sample
		assert_nothing_raised do
			res = @img.sample(10, 10)
			assert_instance_of(Magick::Image, res)
		end
		assert_nothing_raised { @img.sample(2) }
		assert_raise(ArgumentError) { @img.sample }
		assert_raise(ArgumentError) { @img.sample(25, 25, 25) }
		assert_raise(TypeError) { @img.sample('x') }
		assert_raise(TypeError) { @img.sample(10, 'x') }
	end
	
	def test_sample!
		assert_nothing_raised do
			res = @img.sample!(2)
			assert_same(@img, res)
		end
		@img.freeze
		assert_raise(TypeError) { @img.sample!(0.50) }
	end
	
	def test_scale
		assert_nothing_raised do
			res = @img.scale(10, 10)
			assert_instance_of(Magick::Image, res)
		end
		assert_nothing_raised { @img.scale(2) }
		assert_raise(ArgumentError) { @img.scale }
		assert_raise(ArgumentError) { @img.scale(25, 25, 25) }
		assert_raise(TypeError) { @img.scale('x') }
		assert_raise(TypeError) { @img.scale(10, 'x') }
	end
	
	def test_scale!
		assert_nothing_raised do
			res = @img.scale!(2)
			assert_same(@img, res)
		end
		@img.freeze
		assert_raise(TypeError) { @img.scale!(0.50) }
	end
  	
  	def test_segment
  		assert_nothing_raised do
  			res = @img.segment
  			assert_instance_of(Magick::Image, res)
  		end

		ColorspaceTypes.each do |cs|
			assert_nothing_raised { @img.segment(cs) }
		end
		
		assert_nothing_raised { @img.segment(Magick::RGBColorspace, 2.0) }
		assert_nothing_raised { @img.segment(Magick::RGBColorspace, 2.0, 2.0) }
		assert_nothing_raised { @img.segment(Magick::RGBColorspace,  2.0, 2.0, false) }
		
		assert_raise(ArgumentError) { @img.segment(Magick::RGBColorspace, 2.0, 2.0, false, 2) }
		assert_raise(TypeError) { @img.segment(2) }
		assert_raise(TypeError) { @img.segment(Magick::RGBColorspace, 'x') }
		assert_raise(TypeError) { @img.segment(Magick::RGBColorspace, 2.0, 'x') }
  	end
  	
  	def test_sepiatone
   		assert_nothing_raised do
   			res = @img.sepiatone
   			assert_instance_of(Magick::Image, res)
   		end
   		assert_nothing_raised { @img.sepiatone(Magick::MaxRGB*0.80) }
   		assert_raise(ArgumentError) { @img.sepiatone(Magick::MaxRGB, 2) }
   		assert_raise(TypeError) { @img.sepiatone('x') }
  	end
  	
  	def test_set_channel_depth
  		channels = [
			  Magick::RedChannel,
			  Magick::GrayChannel,
			  Magick::CyanChannel,
			  Magick::GreenChannel,
			  Magick::MagentaChannel,
			  Magick::BlueChannel,
			  Magick::YellowChannel,
		#     Magick::AlphaChannel,
			  Magick::OpacityChannel,
			  Magick::MatteChannel,  
			  Magick::BlackChannel,
			  Magick::IndexChannel,
			  Magick::AllChannels] 
  		
  		channels.each do |ch|
  			assert_nothing_raised {@img.set_channel_depth(ch, 8) }
  		end
  	end
  	
  	def test_shade
  		assert_nothing_raised do
  			res = @img.shade
  			assert_instance_of(Magick::Image, res)
  		end
  		assert_nothing_raised { @img.shade(true) }
  		assert_nothing_raised { @img.shade(true, 30) }
  		assert_nothing_raised { @img.shade(true, 30, 30) }
  		assert_raise(ArgumentError) { @img.shade(true, 30, 30, 2) }
  		assert_raise(TypeError) { @img.shade(true, 'x') }
  		assert_raise(TypeError) { @img.shade(true, 30, 'x') }
  	end
  	
  	def test_shadow
  		assert_nothing_raised do
  			res = @img.shadow
  			assert_instance_of(Magick::Image, res)
  		end
  		assert_nothing_raised { @img.shadow(5) }
  		assert_nothing_raised { @img.shadow(5, 5) }
  		assert_nothing_raised { @img.shadow(5, 5, 3.0) }
  		assert_nothing_raised { @img.shadow(5, 5, 3.0, 0.50) }
  		assert_nothing_raised { @img.shadow(5, 5, 3.0, '50%') }
  		assert_raise(ArgumentError) { @img.shadow(5, 5, 3.0, 0.50, 2) }
  		assert_raise(TypeError) { @img.shadow('x') }
  		assert_raise(TypeError) { @img.shadow(5, 'x') }
  		assert_raise(TypeError) { @img.shadow(5, 5, 'x') }
  		assert_raise(ArgumentError) { @img.shadow(5, 5, 3.0, 'x') }
  	end
  	
  	def test_sharpen
  		assert_nothing_raised do
  			res = @img.sharpen
  			assert_instance_of(Magick::Image, res)
  		end
  		assert_nothing_raised { @img.sharpen(2.0) }
  		assert_nothing_raised { @img.sharpen(2.0, 1.0) }
  		assert_raise(ArgumentError) { @img.sharpen(2.0, 1.0, 2) }
  		assert_raise(TypeError) { @img.sharpen('x') }
  		assert_raise(TypeError) { @img.sharpen(2.0, 'x') }
  	end
  	
  	def test_sharpen_channel
  		assert_nothing_raised do
  			res = @img.sharpen_channel
  			assert_instance_of(Magick::Image, res)
  		end
  		assert_nothing_raised { @img.sharpen_channel(2.0) }
  		assert_nothing_raised { @img.sharpen_channel(2.0, 1.0) }
  		assert_nothing_raised { @img.sharpen_channel(2.0, 1.0, Magick::RedChannel) }
  		assert_nothing_raised { @img.sharpen_channel(2.0, 1.0, Magick::RedChannel, Magick::BlueChannel) }
  		assert_raise(TypeError) { @img.sharpen_channel(2.0, 1.0, Magick::RedChannel, 2) }
  		assert_raise(TypeError) { @img.sharpen_channel('x') }
  		assert_raise(TypeError) { @img.sharpen_channel(2.0, 'x') }
  	end
  	
  	def test_shave
  		assert_nothing_raised do
  			res = @img.shave(5,5)
  			assert_instance_of(Magick::Image, res)
  		end
  		assert_nothing_raised do
  			res = @img.shave!(5,5)
  			assert_same(@img, res)
  		end
  		@img.freeze
  		assert_raise(TypeError) { @img.shave!(2,2) }
  	end
  	
  	def test_shear
  		assert_nothing_raised do
  			res = @img.shear(30, 30)
  			assert_instance_of(Magick::Image, res)
  		end
  	end
  	
  	def test_sigmoidal_contrast_channel
  		assert_nothing_raised do
  			res = @img.sigmoidal_contrast_channel
  			assert_instance_of(Magick::Image, res)
  		end
  		assert_nothing_raised { @img.sigmoidal_contrast_channel(3.0) }
  		assert_nothing_raised { @img.sigmoidal_contrast_channel(3.0, 50.0) }
  		assert_nothing_raised { @img.sigmoidal_contrast_channel(3.0, 50.0, true) }
  		assert_nothing_raised { @img.sigmoidal_contrast_channel(3.0, 50.0, true, Magick::RedChannel) }
  		assert_nothing_raised { @img.sigmoidal_contrast_channel(3.0, 50.0, true, Magick::RedChannel, Magick::BlueChannel) }
  		assert_raise(TypeError) { @img.sigmoidal_contrast_channel(3.0, 50.0, true, Magick::RedChannel, 2) }
  		assert_raise(TypeError) { @img.sigmoidal_contrast_channel('x') }
  		assert_raise(TypeError) { @img.sigmoidal_contrast_channel(3.0, 'x') }
  	end
  	
  	def test_signature
  		assert_nothing_raised do
  			res = @img.signature
  			assert_instance_of(String, res)
  		end
  	end
  	
  	def test_solarize
  		assert_nothing_raised do
  			res = @img.solarize
  			assert_instance_of(Magick::Image, res)
  		end
  		assert_nothing_raised { @img.solarize(100) }
  		assert_raise(ArgumentError) { @img.solarize(100, 2) }
  		assert_raise(TypeError) { @img.solarize('x') }
  	end
  	
  	def test_splice
  		assert_nothing_raised do
  			res = @img.splice(0, 0, 2, 2)
  			assert_instance_of(Magick::Image, res)
  		end
  		assert_nothing_raised { @img.splice(0, 0, 2, 2, 'red') }
  		red = Magick::Pixel.new(Magick::MaxRGB)
  		assert_nothing_raised { @img.splice(0, 0, 2, 2, red) }
  		assert_raise(ArgumentError) { @img.splice(0,0, 2, 2, red, 'x') }
  		assert_raise(TypeError) { @img.splice([], 0, 2, 2, red) }
  		assert_raise(TypeError) { @img.splice(0, 'x', 2, 2, red) }
  		assert_raise(TypeError) { @img.splice(0, 0, 'x', 2, red) }
  		assert_raise(TypeError) { @img.splice(0, 0, 2, [], red) }
  		assert_raise(TypeError) { @img.splice(0, 0, 2, 2, /m/) }
  	end
  	
  	def test_spread
  		assert_nothing_raised do
  			res = @img.spread
  			assert_instance_of(Magick::Image, res)
  		end
  		assert_nothing_raised { @img.spread(3.0) }
  		assert_raise(ArgumentError) { @img.spread(3.0, 2) }
  		assert_raise(TypeError) { @img.spread('x') }
  	end
  	
  	def test_statistics
  		begin 
  			@img.statistics
  		rescue NotImplementedError
  			return
  		end
  	end
  	
  	def test_stegano
  		img = Magick::Image.new(100, 100) { self.background_color = 'black' }
  		watermark = Magick::Image.new(10, 10) { self.background_color = 'white' }
  		assert_nothing_raised do
  			res = @img.stegano(watermark, 0)
  			assert_instance_of(Magick::Image, res)
  		end
  	end
  	
  	def test_stereo
  		assert_nothing_raised do
  			res = @img.stereo(@img)
  			assert_instance_of(Magick::Image, res)
  		end
  	end
  	
  	def test_store_pixels
  		pixels = @img.get_pixels(0, 0, @img.columns, 1)
  		assert_nothing_raised do
  			res = @img.store_pixels(0, 0, @img.columns, 1, pixels)
  			assert_same(@img, res)
  		end
  		
  		pixels[0] = 'x'
  		assert_raise(TypeError) { @img.store_pixels(0, 0, @img.columns, 1, pixels) }
  		assert_raise(RangeError) { @img.store_pixels(-1, 0, @img.columns, 1, pixels) }
  		assert_raise(RangeError) { @img.store_pixels(0, -1, @img.columns, 1, pixels) }
  		assert_raise(RangeError) { @img.store_pixels(0, 0, 1+@img.columns, 1, pixels) }
  		assert_raise(RangeError) { @img.store_pixels(-1, 0, 1, 1+@img.rows, pixels) }
  	    assert_raise(IndexError) { @img.store_pixels(0, 0, @img.columns, 1, ['x']) }
  	end
  	
  	def test_strip!
  		assert_nothing_raised do
  			res = @img.strip!
  			assert_same(@img, res)
  		end
  	end
  	
  	def test_swirl
  		assert_nothing_raised do
  			res = @img.swirl(30)
  			assert_instance_of(Magick::Image, res)
  		end
  	end
  	
  	def test_texture_fill_to_border
  		texture = Magick::Image.read('granite:').first
  		assert_nothing_raised do
  			res = @img.texture_fill_to_border(@img.columns/2, @img.rows/2, texture)
  			assert_instance_of(Magick::Image, res)
  		end
  		assert_raise(NoMethodError) { @img.texture_fill_to_border(@img.columns/2, @img.rows/2, 'x') }
  	end
  	
  	def test_texture_floodfill
  		texture = Magick::Image.read('granite:').first
  		assert_nothing_raised do
  			res = @img.texture_floodfill(@img.columns/2, @img.rows/2, texture)
  			assert_instance_of(Magick::Image, res)
  		end
  		assert_raise(NoMethodError) { @img.texture_floodfill(@img.columns/2, @img.rows/2, 'x') }
  	end
	  	
	def test_threshold
		assert_nothing_raised do
			res = @img.threshold(100)
			assert_instance_of(Magick::Image, res)
		end
	end
	
	def test_thumbnail
		assert_nothing_raised do
			res = @img.thumbnail(10, 10)
			assert_instance_of(Magick::Image, res)
		end
		assert_nothing_raised { @img.thumbnail(2) }
		assert_raise(ArgumentError) { @img.thumbnail }
		assert_raise(ArgumentError) { @img.thumbnail(25, 25, 25) }
		assert_raise(TypeError) { @img.thumbnail('x') }
		assert_raise(TypeError) { @img.thumbnail(10, 'x') }
	end
	
	def test_thumbnail!
		assert_nothing_raised do
			res = @img.thumbnail!(2)
			assert_same(@img, res)
		end
		@img.freeze
		assert_raise(TypeError) { @img.thumbnail!(0.50) }
	end
	
	def test_to_blob
		res = nil
		assert_nothing_raised { res = @img.to_blob { self.format = 'miff' } }
		assert_instance_of(String, res)
		restored = Magick::Image.from_blob(res)
		assert_equal(@img, restored[0])
	end
	
	def test_to_color
		red = Magick::Pixel.new(Magick::MaxRGB)
		assert_nothing_raised do
			res = @img.to_color(red)
			assert_equal('red', res)
		end
	end
	
	def test_transparent
		assert_nothing_raised do
			res = @img.transparent('white')
			assert_instance_of(Magick::Image, res)
		end
		pixel = Magick::Pixel.new
		assert_nothing_raised { @img.transparent(pixel) }
		assert_nothing_raised { @img.transparent('white', Magick::TransparentOpacity) }
		assert_raise(ArgumentError) { @img.transparent('white', Magick::TransparentOpacity, 2) }
		assert_nothing_raised { @img.transparent('white', Magick::MaxRGB/2) }
		assert_raise(TypeError) { @img.transparent(2) }
	end
	
	def test_trim
		# Can't use the default image because it's a solid color
		hat = Magick::Image.read(IMAGES_DIR+'/Flower_Hat.jpg').first
		assert_nothing_raised do
			res = hat.trim
			assert_instance_of(Magick::Image, res)
		end
		assert_nothing_raised do
			res = hat.trim!
			assert_same(hat, res)
		end
	end
	
	def test_unsharp_mask
		assert_nothing_raised do
			res = @img.unsharp_mask
			assert_instance_of(Magick::Image, res)
		end
		
		assert_nothing_raised { @img.unsharp_mask(2.0) }
		assert_nothing_raised { @img.unsharp_mask(2.0, 1.0) }
		assert_nothing_raised { @img.unsharp_mask(2.0, 1.0, 0.50) }
		assert_nothing_raised { @img.unsharp_mask(2.0, 1.0, 0.50, 0.10) }
		assert_raise(ArgumentError) { @img.unsharp_mask(2.0, 1.0, 0.50, 0.10, 2) }
		assert_raise(TypeError) { @img.unsharp_mask('x') }
		assert_raise(TypeError) { @img.unsharp_mask(2.0, 'x') }
		assert_raise(TypeError) { @img.unsharp_mask(2.0, 1.0, 'x') }
		assert_raise(TypeError) { @img.unsharp_mask(2.0, 1.0, 0.50, 'x') }
	end
	
	def test_unsharp_mask_channel
		assert_nothing_raised do
			res = @img.unsharp_mask_channel
			assert_instance_of(Magick::Image, res)
		end
		
		assert_nothing_raised { @img.unsharp_mask_channel(2.0) }
		assert_nothing_raised { @img.unsharp_mask_channel(2.0, 1.0) }
		assert_nothing_raised { @img.unsharp_mask_channel(2.0, 1.0, 0.50) }
		assert_nothing_raised { @img.unsharp_mask_channel(2.0, 1.0, 0.50, 0.10) }
		assert_nothing_raised { @img.unsharp_mask_channel(2.0, 1.0, 0.50, 0.10, Magick::RedChannel) }
		assert_nothing_raised { @img.unsharp_mask_channel(2.0, 1.0, 0.50, 0.10, Magick::RedChannel, Magick::BlueChannel) }
		assert_raise(TypeError) { @img.unsharp_mask_channel(2.0, 1.0, 0.50, 0.10, Magick::RedChannel, 2) }
		assert_raise(TypeError) { @img.unsharp_mask_channel(2.0, 1.0, 0.50, 0.10, 2) }
		assert_raise(TypeError) { @img.unsharp_mask_channel('x') }
		assert_raise(TypeError) { @img.unsharp_mask_channel(2.0, 'x') }
		assert_raise(TypeError) { @img.unsharp_mask_channel(2.0, 1.0, 'x') }
		assert_raise(TypeError) { @img.unsharp_mask_channel(2.0, 1.0, 0.50, 'x') }
	end
	
	def test_view
		assert_nothing_raised do
			res = @img.view(0, 0, 5, 5)
			assert_instance_of(Magick::Image::View, res)
		end
		assert_nothing_raised do 
			@img.view(0, 0, 5, 5) { |v| assert_instance_of(Magick::Image::View, v) }
		end
		assert_raise(RangeError) { @img.view(-1, 0, 5, 5) }
		assert_raise(RangeError) { @img.view(0, -1, 5, 5) }
		assert_raise(RangeError) { @img.view(1, 0, @img.columns, 5) }
		assert_raise(RangeError) { @img.view(0, 1, 5, @img.rows) }
		assert_raise(ArgumentError) { @img.view(0, 0, 0, 1) }
		assert_raise(ArgumentError) { @img.view(0, 0, 1, 0) }
	end
	
	def test_wave
		assert_nothing_raised do
			res = @img.wave
			assert_instance_of(Magick::Image, res)
		end
		assert_nothing_raised { @img.wave(25) }
		assert_nothing_raised { @img.wave(25, 200) }
		assert_raise(ArgumentError) { @img.wave(25, 200, 2) }
		assert_raise(TypeError) { @img.wave('x') }
		assert_raise(TypeError) { @img.wave(25, 'x') }
	end
	
    def test_white_threshold
        assert_raise(ArgumentError) { @img.white_threshold }
        assert_nothing_raised { @img.white_threshold(50) }
        assert_nothing_raised { @img.white_threshold(50, 50) }
        assert_nothing_raised { @img.white_threshold(50, 50, 50) }
        assert_nothing_raised { @img.white_threshold(50, 50, 50, 50) }
        assert_raise(ArgumentError) { @img.white_threshold(50, 50, 50, 50, 50) }
        res = @img.white_threshold(50)
        assert_instance_of(Magick::Image,  res)
    end

    # I'm not going to spend a lot of time testing this
    # since so many other tests rely on it working.
    def test_write
        assert_nothing_raised do
            @img.write('temp.gif')
            FileUtils.rm('temp.gif')            
        end
    end
	
	  	
end

if __FILE__ == $0
IMAGES_DIR = '../doc/ex/images'
FILES = Dir[IMAGES_DIR+'/Button_*.gif']
Test::Unit::UI::Console::TestRunner.run(Image3_UT)
end