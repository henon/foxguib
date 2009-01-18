# Copyright (c) 2004-2006 by Henon (meinrad dot recheis at gmail dot com)

# minitest.rb (c) by henon. "meinrad/recheis\\gmx/at".gsub(/\//, ".").gsub(/\\/, "@")
# ruby license
require "test/unit/assertions"
include Test::Unit::Assertions
#use the global variable $testout to redirect test output to an IO object other than STDOUT.
#set $testout to nil if you want to silence the test
$testout=$stdout
$testout.sync=true

#a simple test case. the block contains the implementation of a test case.
#if the return value of the block is true the test case passes. if the block returns false
#or the code inside the block raises an exception the test fails.
#the output of the test is best viewed in the Scite editor which highlights the failed testcases.
#parameters:
#description is a string describing the functionality that is going to be tested by this test case.
#block is a proc object that usually returns a boolean expression which determines the pass-state of the testcase.
#returns true if the test passed, false otherwise
def test(description, &block)
	return unless block_given?
	failed=false
	except=""
	begin
		failed=!yield
	rescue Exception
		failed=true
		except=([$!]+$!.backtrace).join("\n")
	ensure
		f=(failed ? "! " : "")
		s=(failed ? "FAIL #{except}" : "OK")
		if $testout
			$testout.puts "#{f}#{description}" 
			$testout.puts "\t#{s}"
		end
	end
	return !failed
end

#minitests own unit test (selftest)
if __FILE__==$0
	test("minitest return value"){
		$testout=nil
		a=(test("test-testcase"){ true }==true)
		b=(test("test-testcase"){ false }==false)
		$testout=$stdout
		a and b
	}
	test("fail if block raises exception"){
		$testout=nil
		a=(test("test-testcase"){ raise "error" }==false)
		$testout=$stdout
		a
	}
	test("this one fails on purpose:") { 
		assert_nothing_raised{ 
			raise "error" 
		}
	}
end