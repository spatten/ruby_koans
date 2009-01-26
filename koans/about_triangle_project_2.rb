require 'edgecase'

# You need to write the triangle method in the file 'triangle.rb'
require 'triangle.rb'

class AboutTriangleAssignment < EdgeCase::Koan
  # The first assignment did not talk about how to handle errors.
  # Let's handle that part now.
  def test_illegal_triangles_throw_exceptions
    assert_raise(TriangleError) do triangle(0, 0, 0) end
    assert_raise(TriangleError) do triangle(3, 4, -5) end
    assert_raise(TriangleError) do triangle(2, 4, 2) end 
 end
end
  
