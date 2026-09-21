-- Gui to Lua
-- Version: 3.2

-- Instances:

local dinguzhosting_provider = Instance.new("ScreenGui")
local ImageLabel = Instance.new("ImageLabel")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")

-- Properties:

dinguzhosting_provider.Name = "dinguzhosting_provider"
dinguzhosting_provider.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
dinguzhosting_provider.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ImageLabel.Parent = dinguzhosting_provider
ImageLabel.AnchorPoint = Vector2.new(1, 1)
ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel.BackgroundTransparency = 1.000
ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageLabel.BorderSizePixel = 0
ImageLabel.Position = UDim2.new(0.973944783, 0, 0.953703701, 0)
ImageLabel.Size = UDim2.new(0.135487229, 0, 0.0481481478, 0)
ImageLabel.Image = "rbxassetid://128935246226957"
ImageLabel.ImageTransparency = 1

UIAspectRatioConstraint.Parent = ImageLabel
UIAspectRatioConstraint.AspectRatio = 4.910

-- Fade animation:

local TweenService = game:GetService("TweenService")

-- Fade In: 2 seconds
local fadeIn = TweenService:Create(
	ImageLabel,
	TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	{ImageTransparency = 0}
)

fadeIn:Play()
fadeIn.Completed:Wait()

-- Stay visible for 5 seconds
task.wait(5)

-- Fade Out: 2 seconds
local fadeOut = TweenService:Create(
	ImageLabel,
	TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	{ImageTransparency = 1}
)

fadeOut:Play()
fadeOut.Completed:Wait()

-- Destroy the entire GUI
dinguzhosting_provider:Destroy()
