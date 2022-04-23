# stuff to do soon
- your profit should have "*" since might not be true "profit" after gas and stuff
- time to check formatting on all device types again (maybe change from padding/frame confusion?)
    - also double check vocab ("much" vs "much money")
- put delivery fee on bringerselectredorder (clarity check on all screens?)
- add cancel confrimartion (DONT refund stripe fee on cancel if already on maps (charged))
- might be bug with incrementing? double check...
- TESTING!!!!

# shit to do if bored
- TESTING!!!!
- modulate network calls (own classes) 
- modulate dropdown (state createacc, pickupbuy placeorder)
- supposed to use getToken() instead of uid for authing; less secure? later problem...
- editing yourprofile and then going to placeorder acts like keyboard is still up for a second
- placeholder for profile picture looks a bit janky, design a better one and replace on youprofile and map views
- break up UserInfo object in DB and models

# stuff to add later
- small refactor of network calls (can leave in viewModel but perhaps add bringerLoc to firebase calls and modulate Stripe calls)
- inform bringer of orderer cancel
- inform orderer of bringer cancel
- send email receipt of transaction on completion
- handle card declined case for orders
- our db rules are non-existant, should probably add some
- probably need auth headers for all HTTP calls so someone can't remotely do stuff (SECURITY)
- when email is changed the email is only changed in db not auth (login uses creation email)
- slight flickering of keyboard when password fields selected (create)
- item name/description on confirmation screen
- views get funky on very small screen sizes (ipod touch, iphone 8, iphone se)
- databse rules: make user unable to read email, phone number from other users
- custom cropping profile picture
- add push notifications for bringer coming/order complete/etc
- map could be bigger on large devices (ipad especially)


# stackoverflow/github links
- https://stackoverflow.com/questions/64379079/how-to-present-accurate-star-rating-using-swiftui
- https://github.com/onmyway133/blog/issues/844


# manual flow testing
- log in, log out, log in, log out, log in, place order
- createacc, add cc info, place order
- createacc, add bringer info, accept bringer
- place order buy, bringer accept, check instructions, check text/call, bringer complete, check final price too high/ok, check for picture in backend
- place order buy, bringer accept, bringer cancel
- place order buy, bringer accept, orderer cancel
- place order buy, force close app(do bringer end too), check order persistent, orderer cancel
- place order pick-up, bringer accept, check instructions, check text/call, bringer complete
- place order pick-up, bringer accept, bringer cancel
- place order pick-up, bringer accept, orderer cancel
- place order pick-up, force close app(do bringer end too), orderer cancel
- upload profile picture, check for picture in backend
- change password, login new password
- change personal details, check Stripe
- change address, check Stripe
