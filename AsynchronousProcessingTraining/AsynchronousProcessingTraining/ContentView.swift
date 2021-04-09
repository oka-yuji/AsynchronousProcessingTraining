//
//  ContentView.swift
//  AsynchronousProcessingTraining
//
//  Created by 岡優志 on 2021/04/10.
//

import SwiftUI

//
enum MyCustomStringConvertibleError: String, Error, CustomStringConvertible {
  case NoError = "No Error"
  case MoreThanOne = "more than  One"
  case LessThanOne = "less than One"
  var description: String {
    return rawValue
  }
}
 
//
struct ContentView: View {
  @State private var intValue = 5
  
  var body: some View {
    NavigationView{
      VStack {
        Stepper("value: \(intValue)", value: $intValue)
        //
        NavigationLink("calc (but it will finish after a while)  !", destination: ChildView(intValue: intValue))
      }
    }
  }
}
 
//
struct ChildView: View {
  var intValue: Int
  //
  @State private var calcResult: Result<Int, MyCustomStringConvertibleError>?
 
  var body: some View {
    //
    switch calcResult {
      case .success(let int):
        //
        Text("Value is \(int)")
      case .failure(let error):
        //
        Text("Error happened: \(error.description)")
      case nil:
        //
        ProgressView()
          .onAppear(perform: {
              testFunc(value: intValue) { result in
                calcResult = result
              }})
    }
  }
 
  func testFunc(value: Int, completion: @escaping (Result<Int, MyCustomStringConvertibleError>) -> Void) {
    //
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
      let result: Result<Int, MyCustomStringConvertibleError>
      // 
      if value == 1 {
        result = Result.success(value)
      } else if value > 1 {
        result = .failure(.MoreThanOne)
      } else {
        result = .failure(.LessThanOne)
      }
      completion(result)
    }
  }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
