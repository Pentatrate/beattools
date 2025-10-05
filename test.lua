--[[imgui.canvasScale = 2
imgui.canvasScale2 = nil
imgui.canvasScale3 = nil
print(shuv.scale / imgui.canvasScale)
print(imgui.canvas:getDimensions())
print(shuv.scale)
imgui.canvas = love.graphics.newCanvas(project.res.x * imgui.canvasScale, project.res.y * imgui.canvasScale)
imgui.ImGuiStyle.ScaleAllSizes(imgui.GetStyle(), 2)]]