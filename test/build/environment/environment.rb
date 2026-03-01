# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2015-2026, by Samuel Williams.

require "build/environment"

describe Build::Environment do
	let(:environment) {subject.new}
	
	with "#to_s" do
		it "should generate empty string" do
			expect(environment.to_s).to be == "#<Build::Environment {}>"
		end
		
		it "should show update proc" do
			environment = Build::Environment.new do
			end
			
			expect(environment.to_s).to be(:include?, __FILE__)
		end
	end
	
	with "#include?" do
		it "should not include anything" do
			expect(environment.include?(:thing)).to be_falsey
		end
		
		it "should include key" do
			environment[:thing] = 42
			expect(environment.include?(:thing)).to be_truthy
		end
		
		it "should include key if parent includes key" do
			environment[:thing] = 42
			child = Build::Environment.new(environment)
			expect(child.include?(:thing)).to be_truthy
		end
	end
	
	it "should chain environments together" do
		a = Build::Environment.new
		a[:cflags] = ["-std=c++11"]
		
		b = Build::Environment.new(a)
		b[:cflags] = ["-stdlib=libc++"]
		b[:rcflags] = lambda{cflags.reverse}
		
		expect(b.evaluate.to_h).to be == {
			:cflags => ["-std=c++11", "-stdlib=libc++"],
			:rcflags => ["-stdlib=libc++", "-std=c++11"]
		}
	end
	
	it "should resolve nested lambda" do
		a = Build::Environment.new do
			sdk "bob-2.6"
			cflags [->{"-sdk=#{sdk}"}]
		end
		
		b = Build::Environment.new(a) do
			sdk "bob-2.8"
		end
		
		c = Build::Environment.new(b) do
			cflags ["-pipe"]
		end
		
		expect(b.to_h.keys.sort).to be == [:cflags, :sdk]
		
		expect(Build::Environment::System::convert_to_shell(b.evaluate)).to be == {
			"SDK" => "bob-2.8",
			"CFLAGS" => "-sdk=bob-2.8"
		}
		
		expect(c.evaluate[:cflags]).to be == %W{-sdk=bob-2.8 -pipe}
	end
	
	it "should combine environments" do
		a = Build::Environment.new(nil, {:name => "a"})
		b = Build::Environment.new(a, {:name => "b"})
		c = Build::Environment.new(nil, {:name => "c"})
		d = Build::Environment.new(c, {:name => "d"})
		
		top = Build::Environment.combine(b, d)
		
		expect(top.values).to be == d.values
		expect(top.parent.values).to be == c.values
		expect(top.parent.parent.values).to be == b.values
		expect(top.parent.parent.parent.values).to be == a.values
	end
	
	it "should combine defaults" do
		platform = Build::Environment.new do
			os "linux"
			compiler "cc"
			architectures ["-march", "i386"]
		end
		
		expect(platform.to_h).to be == {
			os: "linux",
			compiler: "cc",
			architectures: ["-march", "i386"]
		}
		
		local = Build::Environment.new do
			compiler "clang"
			default architectures ["-march", "i686"]
		end
		
		expect(local.to_h).to be == {
			compiler: "clang",
			architectures: ["-march", "i686"]
		}
		
		combined = Build::Environment.combine(
			platform,
			local
		).flatten
		
		expect(combined.to_h).to be == {
			os: "linux",
			compiler: "clang",
			architectures: ["-march", "i386"]
		}
	end
	
	it "can make key with nil value" do
		environment = Build::Environment.new do
			thing nil
		end
		
		expect(environment.to_h).to be == {thing: nil}
	end
	
	it "can make key with false value" do
		environment = Build::Environment.new do
			thing false
		end
		
		expect(environment.to_h).to be == {thing: false}
	end
	
	it "can make key with hash value" do
		environment = Build::Environment.new do
			thing hash(foo: 10)
		end
		
		expect(environment.to_h).to be == {thing: {foo: 10}}
	end
end
