#--
# Copyright (c) 2013 Colin J. Fuller
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the Software), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#++

require 'nmatrix'
require 'nmatrix_extras'

describe NMatrix do

  before :each do
    @nm_1d = N[5.0,0.0,1.0,2.0,3.0]
    @nm_2d = N[[0.0,1.0],[2.0,3.0]]
  end

  context "_like constructors" do

    it "should create an nmatrix of ones with dimensions and type the same as its argument" do
      NMatrix.ones_like(@nm_1d).should eq N[1.0, 1.0, 1.0, 1.0, 1.0]
      NMatrix.ones_like(@nm_2d).should eq N[[1.0, 1.0], [1.0, 1.0]]
    end

    it "should create an nmatrix of zeros with dimensions and type the same as its argument" do 
      NMatrix.zeros_like(@nm_1d).should eq N[0.0, 0.0, 0.0, 0.0, 0.0]
      NMatrix.zeros_like(@nm_2d).should eq N[[0.0, 0.0], [0.0, 0.0]]
    end

  end

  it "behaves like Enumerable#reduce with no argument to reduce" do
    @nm_1d.reduce_along_dim(0) { |acc, el| acc + el }.to_f.should eq 11
    @nm_2d.reduce_along_dim(1) { |acc, el| acc + el }.should eq N[[1, 5]]
  end

  it "should calculate the mean along the specified dimension" do
    @nm_1d.mean.should eq N[2.2]
    @nm_2d.mean.should eq N[[1.0,2.0]]
  end

  it "should calculate the minimum along the specified dimension" do 
    @nm_1d.min.should eq N[0.0]
    @nm_2d.min.should eq N[[0.0, 1.0]]
    @nm_2d.min(1).should eq N[[0.0], [2.0]]
  end

  it "should calculate the maximum along the specified dimension" do
    @nm_1d.max.should eq N[5.0]
    @nm_2d.max.should eq N[[2.0, 3.0]]
  end

  it "should calculate the variance along the specified dimension" do
    @nm_1d.variance.should eq N[3.7]
    @nm_2d.variance(1).should eq N[[0.5], [0.5]]
  end

  it "should calculate the sum along the specified dimension" do
    @nm_1d.sum.should eq N[11]
    @nm_2d.sum.should eq N[[2], [4]]
  end

  it "should calculate the standard deviation along the specified dimension" do
    @nm_1d.std.should eq N[Math.sqrt(3.7)]
    @nm_2d.std(1).should eq N[[Math.sqrt(0.5)], [Math.sqrt(0.5)]]
  end

  it "should raise an ArgumentError when any invalid dimension is provided" do 
    expect { @nm_1d.mean(3) }.to raise_exception(ArgumentError)
  end

  it "should convert to float if it contains only a single element" do 
    N[4.0].to_f.should eq 4.0
    N[[[[4.0]]]].to_f.should eq 4.0
  end

  it "should raise an index error if it contains more than a single element" do
    expect { @nm_1d.to_f }.to raise_error(IndexError)
  end

  it "should map a block to all elements" do 
    @nm_1d.map { |e| e ** 2 }.should eq N[25.0,0.0,1.0,4.0,9.0]
    @nm_2d.map { |e| e ** 2 }.should eq N[[0.0,1.0],[4.0,9.0]]
  end

  it "should map! a block to all elements in place" do
    fct = Proc.new { |e| e ** 2 }
    expected1 = @nm_1d.map &fct
    expected2 = @nm_2d.map &fct
    @nm_1d.map! &fct
    @nm_1d.should eq expected1
    @nm_2d.map! &fct
    @nm_2d.should eq expected2
  end

end


