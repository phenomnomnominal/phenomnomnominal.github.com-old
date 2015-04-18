# How I tricked our testers into becoming JavaScript developers.

Testing user interfaces is hard. Really hard.

## Some background:

The [website I work on](http://www.trademe.co.nz/) has a team of dedicated testers who do awesome work manually testing the pages that we build, so we can try to ensure that our users have a bug-free experience. However, the site has a ~16 year old codebase, and some pretty complicated business rules, so keeping everything in check is a bit of a nightmare. Some sort of user interface automation has become a necessity, and we have been playing with [**Robot Framework**](http://robotframework.org/) for over a year, with some good results. However, it has some problems:

 * It's pretty slow/hard to make tests and to run them
 * The tests don't work that reliably
 * The tests are cray-cray difficult to maintain

That being said, we have a working set of tests that frequently find bugs for us! This is obviously what it is all about, and every time a bug is found, it totally validates all the effort that needs to be put in to getting an automated UI suite up and running. Despite this, whenever a test fails, we always blame the tests first and run them again a few times - **we still don't trust our tests.**

## How can we fix that?

We have recently started a new project that is giving us the chance to take what we've learnt so far about how to create, use, and maintain our UI test suite, and try to improve the quality of our tests, and therefore our trust in them. Going into it, we knew UI tests would be a huge part of this project, and a key metric of it's success. We decided to do more of what we had already been doing, but also to investigate further and find out what other tools there are out there that can help overcome some of the issues outlined above.

### Cucumber & Gherkin:

The first piece of the puzzle came in the form of [**Cucumber**](https://cukes.info/). **Cucumber** is a tool for converting human-readable test scenarios written in a small language called [**Gherkin**](https://github.com/cucumber/cucumber/wiki/Gherkin). A **Gherkin** *feature* looks something like this:

    # doSomething.feature
    Feature: Do something
        As a human
        I want to do something
        So that I can say feel good about myself
        
        Scenario: Do a thing
           When I do something
           Then I should feel good about myself

The [**CucumberJS**](https://github.com/cucumber/cucumber-js) implementation turns that *feature* into *step definitions* that look like this:

    # whenIDoSomething.js
    this.When('I do something', function(done) {
        done.pending();
    });
    
    # thenIShouldFeelGoodAboutMyself.js
    this.Then('I should feel good about myself', function(done) {
        done.pending();
    });

These stubs are then filled out to perform the action described in the step, and when run all together, should execute the whole test scenario and check that it works! Cool! This is great, because it uses easy to understand language, and **small chunks of interaction which can be reused.** Our testers started working on *features* to cover all our business rules, and we noticed straight away how well they tied in with existing acceptance criteria, and how easy they were for everyone to understand. #win.

### AngularJS & Protractor:

This new project is being built using [**AngularJS**](https://angularjs.org/), and **Angular** already has a tool for writing automated UI tests - [**Protractor**](http://angular.github.io/protractor/#/)! Puzzle piece number 2! **Protractor** allows you to write **JavaScript** code that drivers a browser, in a very similar way to **Robot Framework**. And it works with **Cucumber**! And because everything is based off [**Promises**](https://promisesaplus.com/), there are no more pesky `wait` steps, so the tests are automatically a heap more robust. #morewin. From day one, we jumped into **Protractor** headfirst, and everything was going great. We wrote robust tests over each part of the UI as we developed them, and they ran reliably.

There was a few problems - **developing new site funtionality with Angular was quick, but adding automated tests was slow**. This was especially problematic since we had sold **Angular** as a tool that would help us develop new functionality faster. And unlike **Robot Framework**, **Protractor** tests are written in JavaScript, not with a UI. So even though we sped up quite a bit as we got better at writing them, there was a lot of extra work for our developers to do, and not that much for our testers. As a result of this, UI tests weren't being written frequently, or they were just covering the happy path through the system. Our testers even went back to writing **Robot Framework** tests so that they could more easy test the rapidly changing codebase. Since the codebase was changing so quickly, it became clear that the naive way in which we were approaching writing our *step definitions* also hadn't fixed the maintainability problem. Small changes to the UI meant big refactors of the test code. So while some things had got better, others hadn't, and some new problems had appeared.

#### Better:

 * Modular reuseable step definitions
 * Moar JavaScript (yay!)
 * More reliable tests through robust interaction timing thanks to Promises
 
#### Not better:

 * Still slow to create tests

#### New problems:

 * Whose responsibility should it be to build and maintain UI tests?

### What next?

We'd made some improvements, but the workflow wasn't quite right, and the UI tests we had made weren't good enough. We needed to capture the ability of our testers to think of every way to break things. Could we teach them all **JavaScript**? Absolutely, but how long would it take? We considered just going back to **Robot Framework**, but **Protractor** really is the right tool for the job. What if we could make **Protractor** a bit more like **Robot Framework**? What if we could make a UI for **Protractor** so that anyone could make tests, whether they could write JavaScript or not? 

I decided to give it a go.

## tractor:

Here we are, a few months later, and I've been working on a tool called [**tractor**](https://github.com/TradeMe/tractor), which is hopefully puzzle piece number three! I've still got a lot more to work on it, but our new project now has a suite of about 50 UI test scenarios that were created entirely by our testers using **tractor**. **tractor** is a [**node.js**](https://nodejs.org/) application and browser-based user-interface written in **AngularJS** that allows non-technical people to create and manipulate **JavaScript**, **JSON** and **Gherkin** files which are then consumed by **Protractor**. And as an **Angular** app, it was used to create automated UI tests for itself!

### How does it work?

**tractor** uses a few core ideas and constraints that work together to create more maintainable UI tests.

#### Components:

A **tractor** *component* is my interpretation of a *Page Object* in **Selenium**. *Components* are essentially the key to having maintainable UI tests. A *Component* is a set of named elements (buttons, inputs, etc.) and actions on those elements, that describe the behaviour of a part of a web app. By keeping this behaviour high level, we can keep all the fragility of our tests in one place, which makes them much more maintainable. For example, where before the *step definitions* for logging in may have looked something like this:

    this.When('I type in my username', function (done) {
        element(by.css('#UserName')).sendKeys('username');
        done();
    });
    
    this.When('I type in my password', function (done) {
        element(by.css('#Password')).sendKeys('secret');
        done();
    });
    
    this.When('I click the login button', function (done) {
        element(by.css('#LoginButton')).click();
        done();
    });
    

with a *component* it would look more like this:

    // UserLogin.component.js
    function UserLogin () {
        this.userNameInput = element(by.css('#UserName'));
        this.passwordInput = element(by.css('#Password'));
        this.loginButton = element(by.css('#LoginButton'));
    }
    
    UserLogin.prototype.login = function (username, password) {
        this.userNameInput.sendKeys(username);
        this.passwordInput.sendKeys(password);
        this.loginButton.click();
    };
    
    // WhenILogIn.step.js
    this.When('I log in', function (done) {
        var UserLogin = new UserLogin();
        UserLogin.login('username', 'secret');
    });

Now, the elements are encapsulated by the `UserLogin` component, as well as the specifics of the `login` action. If the exact way that a user logs in should change in the future, the test only needs to be updated in one place. Our current workflow is that a developer uses **tractor** to create *components* as a part of the initial dev work on a feature, as they are in a better position to decide which element selectors will be the most robust.

#### Features and Step Definitions:

Features are created using the same **Gherkin** syntax, but with some additional constraints. The *Given*, *When* and *Then* actions have very specific meanings within **tractor**.

 * A *Given* step is in charge of setting up API calls, which can be mocked using the `$httpBackend` service from **AngularJS**.
 * A *When* step describes a task, which is made up of a set of interactions on some *components*
 * A *Then* step declares an expectation, which is a combination of getting the state of a *component* via an interaction and an expected result.

#### Mock Data:

**tractor** allows users to input mock data as **JSON** and assosciate that data with a given URL. It uses the `$httpBackend` service to intercept AJAX calls and replace the response with the mocked data.
While it expects mock data by default, it will also allow for a call to pass-through to a real server and get real data.

#### Everything is just files:

Because **tractor** directly operates on **JavaScript**, **JSON** and **Gherkin** files, everything can still work as it used to, files can still just be manipulated and merged as you'd expect them to be.

### Try it out!

**tractor** is available on [**Github**](https://github.com/TradeMe/tractor), and can be installed via **npm**, using `npm install -g tractor@alpha`. Please give it a go on your **Angular** app, and let me know how it works for you! We are still a wee way away from a proper release, but until then I will be using this blog to document anything interesting that comes out of the development process!