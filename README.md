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
`const H = awt.PicoCSS(w)` or `const H = awt.JellyUI(w)` or `const H = awt.JackWeasel(w)` or `const H = awt.Stellar(w)` to use the same code
to define the UI, but completely swap out the HTML to match a given UI toolkit.

As you can imagine, this format will get real ugly real fast .. to the point where it resembles a big gaggle of machine generated Assembler.

## And then what ? Where we going wih this ?

```zig
Surely, when you design a UI, you are not going to write a mountain of this
gobble gaggle code just so you can swap toolkits in and out every 5 minutes ?

That seems very silly ?
```

Yes, thats not the intention here.

The point is to build up a way to describe a UI using an abstract widget notation, and once that is working across a number
of component libs, be able to define a DSL to describe these abstract UIs, and edit them in a wysiwyg editor.

The editor could load & save to the DSL format, and then have a compiler that converts DSL code -> working code, in Zig or Go, or whatever rocks your boat.

Thats the end goal.

Design and edit in a GUI with a generic style that is independent of CSS toolkit, compile this to working code in a range of different languages,
then apply whatever CSS toolkit you want at build time.

Then apply those HTML generator functions in your Datastar or other Hypermedia backend.

Want to edit your page contents and UX flow ?  Edit it on your iPad using a GUI, hit generate -> export code to your backend -> rebuild -> done.

Check back in another month or so once I get something working on this abstract assembly format first.

## What GUI ? How is that going to work ?

Im working on another (private) project at the moment that allows for building portable offline apps in Zig + Hypermedia, that compile
to wasm, and run on any Desktop / iOS / Android device as a PWA. Its an offline-first subset of a Datastar-like markup that is
tightly integrated to Web Assembly. 

Will use secret squirrel tool to build a portable GUI editor for this Abstract Widget Toolkit idea, which will make a good example
project for the other project.

Its layers of streams all the way down :)

Thx for reading to the end :)
