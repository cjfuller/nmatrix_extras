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

module NMatrixExtras

  def self.included(base)
    base.extend(ClassMethods)
  end

  ##
  # Successively yields submatrices at each coordinate along a specified dimension.  Each submatrix will have the same number of dimensions as the matrix being iterated,
  # but with the specified dimension's size equal to 1.
  #
  # @param [Integer] dim the dimension being iterated over.
  #
  def each_along_dim(dim=0) 
    dims = shape
    shape.each_index { |i| dims[i] = 0...(shape[i]) unless i == dim }
    0.upto(shape[dim]-1) do |i|
      dims[dim] = i
      yield self[*dims]
    end
  end

  ##
  # Reduces an NMatrix using a supplied block over a specified dimension.  The block should behave the same way as for Enumerable#reduce.
  #
  # @param [Integer] dim the dimension being reduced
  # @param [Numeric] initial the initial value for the reduction (i.e. the usual parameter to Enumerable#reduce).  Supply nil or do not supply
  #  this argument to have it follow the usual Enumerable#reduce behavior of using the first element as the initial value.
  # @return [NMatrix] an NMatrix with the same number of dimensions as the input, but with the input dimension now having size 1.  
  #    Each element is the result of the reduction at that position along the specified dimension.
  #
  def reduce_along_dim(dim=0, initial=nil, &bl)

    if dim > shape.size then
      raise ArgumentError, "Requested dimension does not exist.  Requested: #{dim}, shape: #{shape}"
    end

    new_shape = shape
    new_shape[dim] = 1

    first_as_acc = false

    if initial then
      acc = NMatrix.new(new_shape, initial)
    else
      each_along_dim(dim) do |sub_mat|
        acc = sub_mat
        break
      end
      first_as_acc = true
    end

    each_along_dim(dim) do |sub_mat|
      if first_as_acc then
        first_as_acc = false
        next
      end
      acc = bl.call(acc, sub_mat)
    end

    acc

  end

  alias_method :inject_along_dim, :reduce_along_dim

  ##
  # Calculates the mean along the specified dimension.
  #
  # @see #reduce_along_dim
  #
  def mean(dim=0)
    reduce_along_dim(dim, 0.0) do |mean, sub_mat|
      mean + sub_mat/shape[dim]
    end
  end

  ##
  # Calculates the sum along the specified dimension.
  #
  # @see #reduce_along_dim
  def sum(dim=0)
    reduce_along_dim(dim, 0.0) do |sum, sub_mat|
      sum + sub_mat
    end
  end


  ##
  # Calculates the minimum along the specified dimension.
  #
  # @see #reduce_along_dim
  #
  def min(dim=0)
    reduce_along_dim(dim, Float::MAX) do |min, sub_mat|
      min * (min <= sub_mat) + ((min)*0.0 + (min > sub_mat)) * sub_mat
    end
  end

  ##
  # Calculates the maximum along the specified dimension.
  #
  # @see #reduce_along_dim
  #
  def max(dim=0)
    reduce_along_dim(dim, -1.0*Float::MAX) do |max, sub_mat|
      max * (max >= sub_mat) + ((max)*0.0 + (max < sub_mat)) * sub_mat
    end
  end


  ##
  # Calculates the sample variance along the specified dimension.
  #
  # @see #reduce_along_dim
  #
  def variance(dim=0)
    m = mean(dim)
    reduce_along_dim(dim, 0.0) do |var, sub_mat|
      var + (m - sub_mat)*(m - sub_mat)/(shape[dim]-1)
    end
  end

  ##
  # Calculates the sample standard deviation along the specified dimension.
  #
  # @see #reduce_along_dim
  #
  def std(dim=0)
    variance(dim).map! { |e| Math.sqrt(e) }
  end

  ##
  # Converts an nmatrix with a single element (but any number of dimensions) to a float.
  #
  # Raises an IndexError if the matrix does not have just a single element.
  #
  def to_f
    raise IndexError, 'to_f only valid for matrices with a single element' unless shape.all? { |e| e == 1 }
    self[*Array.new(shape.size, 0)]
  end

  ##
  # See Enumerable#map
  #
  def map(&bl)
    cp = self.dup
    cp.map! &bl
    cp
  end

  ##
  # Maps in place.
  # See #map
  #
  def map!
    self.each_stored_with_indices do |e, *i|
      self[*i] = (yield e)
    end
    self
  end

  module ClassMethods

    def ones_like(nm)
      NMatrix.ones(nm.shape, nm.dtype)
    end

    def zeros_like(nm)
      NMatrix.zeros(nm.stype, nm.shape, nm.dtype)
    end

  end

end
