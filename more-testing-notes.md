So it definitely becomes easier to bind to our data model if we wrap all our fields in

ControlValue<T> class that has get and set methods on it because then our control can interact directly with the data model. 

But then it adds anothe rlayer of abstraction and means we don't have a neat way of serialising to JSON, because now we need to map this kind of View-Model designed class to a data class. 



Can the bloc just create a FormControl for each field individually rather than putting them all together? 

How do we test the form then though? Or do we just go back to using JSON keys? And our test needs to test that every field ends up in the data model anyway. 

So I didn't like angular forms because of the lack of explicit binding to a data model. 

however, as I've said before, we still need the tests. So the only thing I really want to add is the ability to construct a single validator

So is there a way we can construct a validator function such that it can be compared with others? Can we have const functions? No it can't be const because the string messages are dynamic. 

Do we just build a simple wrapper around the FormControl that composes the validator function? Maybe that's better? 

ValidatedControl

Now what implications does this have? We're basically not going to be able to use angular forms package, we'll need our own. 

Well this is kinda interesting: 
```js
ValidatorFn normalizeValidator(dynamic validator) {
  if (validator is Validator) {
    return (c) => validator.validate(c);
  } else if (validator is Function) {
    return validator as ValidatorFn;
  } else {
    return validator.call as ValidatorFn;
  }
}
```

Hmm yeah I think doing it through Angular forms could bring some benefits in terms of the code I need to write to enable everything. 

So many concepts I like are already there. 

Except there are things that are intended to be used internally by the view binding that we need to use in flutter and consequently in our angular apps. 

ValidatedControl

Screw it, lets do with JSON conversion. We maintain all the data as Map<String, dynamic> 


So the angular implementation allows emitting values from the model (form) to the view via a callback

Other changes flow in the other direction.

So there's two way data flow - the control has a reference to a function it can use to update the view (which we've been thinking is a stream)

state could include modelToViewUpdate? That triggers a push to the view. 

I really like these validators being equatable classes. They have very nice predictable behaviours this way, outputting consistent errors. 

Okay lets assume that they all have a hashcode. We can sort them by that hashcode. 

Okay we might be able to use angular forms. This would be pretty neat. We can natively bind angular stuff directly to it with no effort, and we just need to write widgets that know how to interact with the angular components. 

Is it a little bit strange to use angular things in flutter? yeah but honestly, I don't want to repeat all that logic and testability, I just want to use some logic that works. And its not angular-specific is the nice thing. 

Yeah cool dart by default runs through the list of items expecting them all to be identical. So hashcode sorting at the start sounds fun. 

Hmm while this test will work, it won't make great error messages though. We'll have no idea what was missing, just that two functions were different. 

Okay we can create a function object and override its toString to print the list of validators that created it. This is pretty cool! That way we get visual feedback about the difference. 

Okay == must be failing, the containers don't know that theya re the same despite having the same hashcode. 

Okay expect does check element wise, but equality by default doesn't check. 

Okay I think we've been able to create a avlidator function now. 

So now we need to check to see if we can actually use angular forms. I don't know if it is a standalone package? I hope so. 

So I'm just hoping there are no dependencies that use mirrors or otherwise compilation will fail. 

Validator functions take the contorl itself rather than the value. Dammit. 

Hmm what about auto-validate vs not>? 

We might need to just use the 'touched' attribute instead. Maybe we can show the errors straight away on touch? Why not. For array things we can set everything to touched on validate. 

So how do we build a field now? 

We need to register on change. Let's just do a text field. 

Does statusChanges update when the status stays invalid? 

Okay it always emits even if the value is the same. That's okay. 

so i'm expecting failure here because my avlidators take values rather than abstract controls. 

Crap yeah angular forms has dependencies on dart:html which is not included with the dart SDK bundled with flutter. 



So I think we can't use AngularForms. We can copy the text out of it though. 

Yeah we have to fork angular forms. Dammit. 

Crap balls. This still isn't working. Once its been type-defd, it doesn't even carry around the toString function properly

Okay we've replaced ValidatorSet<T> everywhere that ValidatorFn was since they work the same. And its also a self-contained library, which is good. 

So we're just not going to use angular forms. 

We'll call it dart_forms or something - a pure dart implementation used for defining easily-testable form controls, inspired by angular_forms. 
Then we'll have two related packages:
- angular_dart_forms: binds standard dart forms to angular components (copy-paste existing angular-forms library)
- flutter_dart_forms: binds standard dart forms to flutter widgets

So if we do this, what next? Let's test it in the actual app. 

Fuck you so much. I hate it when gradle has problems. They never make any fucking sense. 

How much danger are we exposing ourselves here to though? Maybe we should fork angular instead? 

The gradle folder is huge that I'm deleting to clean this out. 

Okay but its not a particularly large module. 

So let's put our validator sets in another file. 

This will make a reasonable amount of sense, we just need to document it sufficiently. 

The aim is for less code, but we need tests as well. And this makes tests so damn simple. 

Maybe we can trick a function into having properties by making it extend function. need to test. Don't really know about Dart type safety. But dammit this is working no where near as well as I would have liked. 

Although what I currenlty have is what we were going to need to do anyway. So it makes sense to copy angular because at least it has the options and the documentation already there. 

Okay it finally built. But it sucks. 

Okay so its working. And individual field is. So next up we need to get groups working. And also figure out when to display the errors. 

So TextField doesn't give us a good way to know on blur - we have to use a FocusScope instead which means that we need to have this listeners outside the form that we are actually tryiing to work with. 

So I think we need another way to say whether to validate or not. 

Shall we add the autoValidate flag? That way we can set it to false originally

This is not working. It's really not. What the hell is wrong with it. 

So, the library assumes we can know when a field is blurred. But where we need to 

But it means we need to jump through some hoops for the data-binding to flow around. 

Perhaps we should just listen to valueChanges instead and rebuild accordingly. 

Dirty and touched don't actually help. We want to display errors after touch, but touch doesn't trigger validation. Dirty does. So we have to mark it as dirty. 

Okay its starting to look a bitt better now. Errors show up as they are entered using 'touched'

So "validate" button can mark everything as touched, and trigger a rebuild of everything. 

Except I don't think there's a value and validitiy for the entire form. 

## Not using Angular Forms
So here's a little thought. We can't use the core angular forms since it has dependencies on dart SDK components not included with flutter, like dart:html. So we want to write our own library. In this case, there's not much point copying angular, let's just do our own thing sna dhave enough tests in place so that it behaves how we expected. 