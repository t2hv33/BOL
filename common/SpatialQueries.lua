-- Code ------------------------------------------------------------------------

class 'Point' -- {
	function Point:__init(x, y)
		self.x = x
		self.y = y

		self.points = {self}
	end

	function Point:__type()
		return "Point"
	end

	function Point:__eq(spatialObject)
		if spatialObject:__type() ~= "Point" then
			return false
		else
			return self.x == spatialObject.x and self.y == spatialObject.y
		end
	end

	function Point:getPoints()
		return self.points
	end

	function Point:contains(spatialObject)
		for i, point in ipairs(spatialObject:getPoints()) do
			if point ~= self then
				return false
			end
		end

		return true
	end

	function Point:insideOf(spatialObject)
		return spatialObject.contains(self)
	end
-- }

class 'Line' -- {
	function Line:__init(point1, point2)
		self.point1 = point1
		self.point2 = point2

		self.points = {self.point1, self.point2}
	end

	function Line:__type()
		return "Line"
	end

	function Line:__eq(spatialObject)
		if spatialObject:__type() ~= "Line" then
			return false
		else
			return (self.point1 == spatialObject.point1 and self.point2 == spatialObject.point2) or
			       (self.point2 == spatialObject.point1 and self.point1 == spatialObject.point2)
		end
	end

	function Line:getPoints()
		return self.points
	end

	function Line:contains(spatialObject)
		if spatialObject:__type() == "Line" or spatialObject:__type() == "Point" then
			for i, point in ipairs(spatialObject:getPoints()) do
				if self:distance(point) ~= 0 then
					return false
				end
			end

			return true
		elseif spatialObject:__type() == "LineSegment" then
			return false -- TODO
		end

		return false
	end

	function Line:insideOf(spatialObject)
		return spatialObject.contains(self)
	end

	function Line:distance(spatialObject)
		minDistance = nil
		for i, point in ipairs(spatialObject:getPoints()) do
			m = (self.point2.y - self.point1.y) / (self.point2.x - self.point1.x)

			distance = math.abs((m * point.x - point.y + (self.point1.y - m * self.point1.x)) / math.sqrt(m * m + 1))
			if minDistance == nil or distance <= minDistance then
				minDistance = distance
			end
		end

		return minDistance
	end
-- }

class 'Circle' -- {
	function Circle:__init(point, radius)
		self.point = point
		self.radius = radius

		self.points = {self.point}
	end

	function Circle:__type()
		return "Circle"
	end

	function Circle:__eq(spatialObject)
		if spatialObject:__type() ~= "Circle" then
			return false
		else
			return (self.point == spatialObject.point and self.radius == spatialObject.radius)
		end
	end

	function Circle:getPoints()
		return self.points
	end

	function Circle:contains(spatialObject)
		if spatialObject:__type() == "Line" then
			return false
		end

		if spatialObject:__type() == "Circle" then
			return self.radius >= spatialObject.radius + self.point:distance(spatialObject.point)
		end

		for i, point in ipairs(spatialObject:getPoints()) do
			if self.point:distance(point) >= self.radius then
				return false
			end
		end

		return true
	end

	function Circle:insideOf(spatialObject)
		return spatialObject.contains(self)
	end

	function Circle:distance(spatialObject)
		if spatialObject:__type() == "Line" then
			return spatialObject:distance(self.point) - self.radius
		end

		if spatialObject:__type() == "Circle" then
			return self.radius >= spatialObject.radius + self.point:distance(spatialObject.point)
		end

		minDistance = nil
		for i, point in ipairs(spatialObject:getPoints()) do
			m = (self.point2.y - self.point1.y) / (self.point2.x - self.point1.x)

			distance = math.abs((m * point.x - point.y + (self.point1.y - m * self.point1.x)) / math.sqrt(m * m + 1))
			if minDistance == nil or distance <= minDistance then
				minDistance = distance
			end
		end

		return minDistance
	end

	function Circle:intersectionPoints(spatialObject)
		result = {}

		dx = self.point.x - spatialObject.point.x
		dy = self.point.y - spatialObject.point.y
		dist = math.sqrt(dx * dx + dy * dy)

		if dist > self.radius + spatialObject.radius then
			return result
		elseif dist < math.abs(self.radius - spatialObject.radius) then
			return result
		elseif (dist == 0) and (self.radius == spatialObject.radius) then
			return result
		else
			a = (self.radius * self.radius - spatialObject.radius * spatialObject.radius + dist * dist) / (2 * dist)
			h = math.sqrt(self.radius * self.radius - a * a)

			cx2 = self.point.x + a * (spatialObject.point.x - self.point.x) / dist
			cy2 = self.point.y + a * (spatialObject.point.y - self.point.y) / dist

			intersectionx1 = cx2 + h * (spatialObject.point.y - self.point.y) / dist
			intersectiony1 = cy2 - h * (spatialObject.point.x - self.point.x) / dist
			intersectionx2 = cx2 - h * (spatialObject.point.y - self.point.y) / dist
			intersectiony2 = cy2 + h * (spatialObject.point.x - self.point.x) / dist

			table.insert(result, Point(intersectionx1, intersectiony1))

			if intersectionx1 ~= intersectionx2 or intersectiony1 ~= intersectiony2 then
				table.insert(result, Point(intersectionx2, intersectiony2))
			end

--			return {Point(intersectionx1, intersectiony1), Point(intersectionx2, intersectiony2)}
		end

		return result
	end
-- }

class 'Triangle' -- {
	function Triangle:__init(point1, point2, point3)
		self.point1 = point1
		self.point2 = point2
		self.point3 = point3

		self.points = {self.point1, self.point2, self.point3}
	end

	function Triangle:__type()
		return "Triangle"
	end

	function Triangle:__eq(spatialObject)
		if spatialObject:__type() ~= "Triangle" then
			return false
		else
			return (self.point1 == spatialObject.point1 and self.point2 == spatialObject.point2 and self.point3 == spatialObject.point3) or
			       (self.point1 == spatialObject.point2 and self.point2 == spatialObject.point3 and self.point3 == spatialObject.point1) or
			       (self.point1 == spatialObject.point3 and self.point2 == spatialObject.point1 and self.point3 == spatialObject.point2)
		end
	end

	function Triangle:getPoints()
		return self.points
	end

	function Triangle:contains(spatialObject)
		for i, point in ipairs(spatialObject:getPoints()) do
		corner1DotCorner2 = ((point.y - self.point1.y) * (self.point2.x - self.point1.x)) - ((point.x - self.point1.x) * (self.point2.y - self.point1.y))
		corner2DotCorner3 = ((point.y - self.point2.y) * (self.point3.x - self.point2.x)) - ((point.x - self.point2.x) * (self.point3.y - self.point2.y))
		corner3DotCorner1 = ((point.y - self.point3.y) * (self.point1.x - self.point3.x)) - ((point.x - self.point3.x) * (self.point1.y - self.point3.y))

		if not (corner1DotCorner2 * corner2DotCorner3 >= 0 and corner2DotCorner3 * corner3DotCorner1 >= 0) then
			return false
		end
	end

	return true
	end

	function Triangle:insideOf(spatialObject)
		return spatialObject.contains(self)
	end
-- }

class 'Quadrilateral' -- {
	function Quadrilateral:__init(point1, point2, point3, point4)
		self.point1 = point1
		self.point2 = point2
		self.point3 = point3
		self.point4 = point4

		self.points = {self.point1, self.point2, self.point3, self.point4}
		self.lines = {Line(self.point1, self.point2), Line(self.point2, self.point3), Line(self.point3, self.point4), Line(self.point4, self.point1)}
	end

	function Quadrilateral:__type()
		return "Quadrilateral"
	end

	function Quadrilateral:__eq(spatialObject)
		if spatialObject:__type() ~= "Quadrilateral" then
			return false
		else
			return (self.point1 == spatialObject.point1 and self.point2 == spatialObject.point2 and self.point3 == spatialObject.point3 and self.point4 == spatialObject.point4) or
			       (self.point1 == spatialObject.point2 and self.point2 == spatialObject.point3 and self.point3 == spatialObject.point4 and self.point4 == spatialObject.point1) or
			       (self.point1 == spatialObject.point3 and self.point2 == spatialObject.point4 and self.point3 == spatialObject.point1 and self.point4 == spatialObject.point2) or
			       (self.point1 == spatialObject.point4 and self.point2 == spatialObject.point1 and self.point3 == spatialObject.point2 and self.point4 == spatialObject.point3)
		end
	end

	function Quadrilateral:getPoints()
		return self.points
	end

	function Quadrilateral:getLines()
		return self.lines
	end

	function Quadrilateral:triangulate()
		if self.triangles == nil then
			self.triangles = {Triangle(self.point1, self.point2, self.point3), Triangle(self.point1, self.point3, self.point4)}
		end

		return self.triangles
	end

	function Quadrilateral:contains(spatialObject)
		for i, point in ipairs(spatialObject:getPoints()) do
			inTriangles = false
			for j, triangle in ipairs(self:triangulate()) do
				if triangle:contains(point) then
					inTriangles = true
					break
				end
			end
			if not inTriangles then
				return false
			end
		end

		return true
	end

	function Quadrilateral:insideOf(spatialObject)
		return spatialObject.contains(self)
	end
-- }
