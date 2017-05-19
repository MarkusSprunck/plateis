# PLATEIS - Traveling Salesmen Game for iOS 

Finding the shortest path between some nodes is simple, but with an increasing number of nodes the task gets extremely difficult to solve. 

You will play in ten worlds with sixteen levels each and the challenge is increasing in the higher worlds. Use the hint function in the case you've got stuck in one level. The hint function shows the minimal expected solution for two-seconds. 

## In the iTunes Store

The application is free of charge. There is just one in-app purcase (jump int next world), but it is possible to play without it.

[https://itunes.apple.com/us/app/plateis/id1141912894](https://itunes.apple.com/us/app/plateis/id1141912894)

## Look & Feel

The user interface is as simple as possible. Just a white background and the standard colors of iOS. 

<table>
  <col width="18%">
  <col width="18%">
  <col width="18%">
  <col width="18%">
  <col width="18%">
  <tr>
    <td><img src="/images/plateis-screen-01.jpg" alt="test image size"  width="100%"></td>
    <td><img src="/images/plateis-screen-02.jpg" alt="test image size"  width="100%"></td>
    <td><img src="/images/plateis-screen-03.jpg" alt="test image size"  width="100%"></td>
    <td><img src="/images/plateis-screen-04.jpg" alt="test image size"  width="100%"></td>
    <td><img src="/images/plateis-screen-05.jpg" alt="test image size"  width="100%"></td>
  </tr>
 </table>

There are two possible models for the traveling salesmen game: 
1. Expert mode (the most difficult one) and 
2. Standard mode (more simple). 

Many people gave me the feedback that the first versions have been to difficult. This is the reason why I intruced two different models. Model number 1 is the inital model with a lot of nodes in the lower levels and the model number 2 has less nodes. 

## Technology
- developed with *Xcode 8.3.2* (requires a Mac running macOS 10.12 or later) 
- All the code is *Swift 3* 
- Devloped on a MacBook Pro (Retina 13 Zoll, Begin 2015) 
- Mac OS 10.12.4 
- Tested on iPhone SE, iPhone 6s, iPhone 5s and iPad 2
- Some basic unit and UI tests are implmented (here is still a lot to do)

## Best Solutions 
- solved with Simulated Annealing
- when pressing the hint button the best solution is showed for two seconds
- it is not guaranted that it is realy the best, but better than a human may find
- number of possible routes are: (n-1)!/2 


  |  nodes | routes      |
  |--------|-------------|
  |  4     | 3           |
  |  5     | 12          |
  |  6     | 60          |
  |  7     | 360         |
  |  8     | 2520        |
  |  9     | 20160       |
  |  10    | 181440      |
  |  11    | 1814400     |
  |  12    | 19958400    |
  |  13    | 239500800   |
  |  14    | 3113510400  |
  |  15    | 43589145600 |

As you can see the number of possible combinations increases dramaticaly with a higher number of nodes. It is surprising that humans are able to solve a TSM with 15 and more nodes. At least with some training.


