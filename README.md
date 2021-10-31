# Windows Terminal Shaders

A collection of shaders I wrote to test out the windows terminal but they also kinda look good.

## The Shaders

| Name | Preview |
| ---- | ------- |
| Julia | ![Julia Preview](./rsrc/julia-demo-com.gif) |
| Paint | ![Paint demo](./rsrc/paint-demo-com.gif) |
| Gold Agate | ![Gold Agate](./rsrc/gold-agate-demo-com.gif) |

## Usage

Open up Windows Terminal `settings.json` file, and add this attribute to any of your profiles:

```
"experimental.pixelShaderPath" : <path to .hlsl file>
```