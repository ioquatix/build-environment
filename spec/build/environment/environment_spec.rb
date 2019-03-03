# Copyright, 2012, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'build/environment'

RSpec.describe Build::Environment do
	context '#to_s' do
		it "should generate empty string" do
			expect(subject.to_s).to be == "#<Build::Environment {}>"
		end
		
		it "should show update proc" do
			environment = Build::Environment.new do
			end
			
			expect(environment.to_s).to be =~ /environment_spec.rb/
		end
	end
	
	context '#include?' do
		it "should not include anything" do
			expect(subject.include?(:thing)).to be_falsey
		end
		
		it "should include key" do
			subject[:thing] = 42
			expect(subject.include?(:thing)).to be_truthy
		end
		
		it "should include key if parent includes key" do
			subject[:thing] = 42
			child = Build::Environment.new(subject)
			expect(child.include?(:thing)).to be_truthy
		end
	end
	
	it "should chain environments together" do
		a = Build::Environment.new
		a[:cflags] = ["-std=c++11"]
		
		b = Build::Environment.new(a)
		b[:cflags] = ["-stdlib=libc++"]
		b[:rcflags] = lambda {cflags.reverse}
		
		expect(b.evaluate).to be == {
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
			'SDK' => "bob-2.8",
			'CFLAGS' => "-sdk=bob-2.8"
		}
		
		expect(c.evaluate[:cflags]).to be == %W{-sdk=bob-2.8 -pipe}
	end
	
	it "should combine environments" do
		a = Build::Environment.new(nil, {:name => 'a'})
		b = Build::Environment.new(a, {:name => 'b'})
		c = Build::Environment.new(nil, {:name => 'c'})
		d = Build::Environment.new(c, {:name => 'd'})
		
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
		
		expect(platform).to be == {
			os: "linux",
			compiler: "cc",
			architectures: ["-march", "i386"]
		}
		
		local = Build::Environment.new do
			compiler "clang"
			default architectures ["-march", "i686"]
		end
		
		expect(local).to be == {
			compiler: "clang",
			architectures: ["-march", "i686"]
		}
		
		combined = Build::Environment.combine(
			platform,
			local
		).flatten
		
		expect(combined).to be == {
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
