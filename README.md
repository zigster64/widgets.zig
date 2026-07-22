# Widgets

An Abstract Widget Toolkit for Zig

## Status

Experiment / hacking the ideas out.

This API will change radically, often.

## Scope

This library defines an interface for structs that :
- Contain short functions to emit HTML fragments to an Io.Writer
- Take parameters to control attribs in the emitted HTML

And a variety of implementations that :
- Customise the emitted HTML to conform to a particular CSS/WebComponent framework

For example, a DaisyUI implementation, another one for PicoCSS, another one for JellyUI, etc.

So then in your code, you might define your markup like this :

```zig
pub fn render(w: Writer) !void {
    const H = DaisyUI(w);

    const card = try H.card();
    defer card.close();

    const l = try H.ul();
    defer l.close();

    for (things) |thing| {
        try H.li(.{.text = thing.name, .on = .{.event = "click", .action = "@function({s})"}}, .{thing.id});
    }
}
```

... something like that.

Then swap out the declaration of 
`const H = PicoCSS(w)` or `const H = JellyUI(w)` to use the same code to define the UI, but completely swap out the HTML
to match a given UI toolkit.

## And then what ?

Surely, when you design a UI, you are not going to swap toolkits in and out every 5 minutes ? That seems silly ?

Yes, thats not the intention here.

The point is to build up a way to describe a UI using abstract widgets, and once that is working across a number
of component libs, be able to define a DSL to describe these abstract UIs in a WysiWyg editor.

The editor could load & save to the DSL format, and then have a compiler that converts DSL code -> Zig functions (or Go, 
or whatever rocks your boat)

Thats the end goal.

Check back in another month or so once I get something working.

Thx for reading to the end :)
