# HotProspects

**Project description.**

![](gif.gif)

#### Technologies used:
- SwiftUI (@EnvironmentObject, TabView)

## Day 79

### @EnvironmentObject

Environment objects use the same ObservableObject protocol as @ObservedObject.

```Swift
struct ContentView: View {
    let user = User()

    var body: some View {
        VStack {
            EditView()
            DisplayView()
        }.environmentObject(user)
    }
} 

struct EditView: View {
    @EnvironmentObject var user: User

    var body: some View {
        TextField("Name", text: $user.name)
    }
}
```

That @EnvironmentObject property wrapper will automatically look for a User instance in the environment, and place whatever it finds into the user property. If it can’t find a User in the environment the app will just crash.

### TabView & the tabItem() modifier 

```Swift
TabView {
    Text("Tab 1")
        .tabItem {
            Image(systemName: "star")
            Text("One")
        }

    Text("Tab 2")
        .tabItem {
            Image(systemName: "star.fill")
            Text("Two")
        }
} 
```



