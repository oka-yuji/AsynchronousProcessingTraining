//
//  ContentView.swift
//  AsynchronousProcessingTraining
//
//  Created by 岡優志 on 2021/04/10.
//

import SwiftUI

//エラー原因情報を含む MyuCustomStringConvertibleError を定義
enum MyCustomStringConvertibleError: String, Error, CustomStringConvertible {
  case NoError = "成功！"
  case MoreThanOne = "数字が大きいです"
  case LessThanOne = "数字が小さいです"
  var description: String {
    return rawValue
  }
}
 
//起動時の画面を定義。値設定のスライダーと下位ビューへ遷移するためのボタンを表示
struct ContentView: View {
  @State private var intValue = 5
  
  var body: some View {
    NavigationView{
      VStack {
        Stepper("value: \(intValue)", value: $intValue)
        //押下されるとステッパーで指定された値を下位ビューへ渡して遷移する
        NavigationLink("実行!", destination: ChildView(intValue: intValue))
      }
    }
  }
}
 
//NavigationLink で遷移する下位ビュー
struct ChildView: View {
  var intValue: Int
  //非同期を想定した関数の実行結果を保持する Result の定義
  @State private var calcResult: Result<Int, MyCustomStringConvertibleError>?
 
  var body: some View {
    //保持している Result の状態によって、表示を切り替える switch 文
    switch calcResult {
      case .success(let int):
        //Result が .success の状態であれば、結果を Text ビューで表示
        Text("成功 \(int)")
      case .failure(let error):
        //Result が .failure の状態であれば、エラーの詳細情報を Text ビューで表示
        Text("Error happened: \(error.description)")
      case nil:
        //Result が nil であれば、まだ計算が終了していないので、ProgressView を表示 ChildView へ遷移したときには、Result は nil なので、.onAppear を使用して、ChildView 遷移時に関数実行開始
        ProgressView()
          .onAppear(perform: {
              testFunc(value: intValue) { result in
                calcResult = result
              }})
    }
  }
 
  func testFunc(value: Int, completion: @escaping (Result<Int, MyCustomStringConvertibleError>) -> Void) {
    //実行される関数。非同期を想定しているので、1秒待ってから completion を呼ぶ
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
      let result: Result<Int, MyCustomStringConvertibleError>
      //渡された値が 1 であれば、成功として 1 を返し、そうでなければ、”1 より大なのでエラー”、”1　より小なのでエラー”という情報を付与してエラーを返す
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
