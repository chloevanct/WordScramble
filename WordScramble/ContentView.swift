//
//  ContentView.swift
//  WordScramble
//
//  Created by Chloe Van on 2024-01-16.
//

import SwiftUI

// root view
struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var gameScore = 0
    
    @State private var allWords = [String]()
    
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        // doesn't capitalize anything when you start typing
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    // id: \.self means each word in used word array is unique
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            // SF Symbols provides numbers in circles from 0 through 50, all named using the format “x.circle.fill” – so 1.circle.fill, 20.circle.fill.
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Score: \(gameScore)")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Restart", action: restartGame)
                }
            }
            // onSubmit is triggered when any text is submitted, it has to be given a function that accepts no parameters and returns nothing.
            .onSubmit(addNewWord)
            // so when this view is shown, pick a random word
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // can't add same words with case differences or leading or trailing white space
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // continue only if there is at least one character in the answer string
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation{
            // please animate whats in this body
            usedWords.insert(answer, at: 0)
            gameScore += 1
        }
        newWord = ""
            
    }
    
    // loads everything for the game
    func startGame() {
        // if you find this file
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                // if you get the contents as a single string
                allWords = startWords.components(separatedBy: "\n")
                // then seperate the single long string by each line break to make an array of each word as each element
                // now pick random word from here and assign it to the rootWord
                rootWord = allWords.randomElement() ?? "silkworm" // don't forget to handle with nil colescing because its not guarenteed that randomElement will always be called on a non-empty array
                
                restartGame()
                return
            }
        }
        // if any of the above body has error we can't run the game in a broken state so we want to call fatalError - unconditionally causes our app to crash
        fatalError("Coule not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            // if we find this letter in our temporary word
            if let pos = tempWord.firstIndex(of: letter) {
                // remove the letter so it can't be used again in temp word
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return mispelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func restartGame() {
        gameScore = 0
        usedWords.removeAll()
        newWord = ""
        rootWord = allWords.randomElement() ?? "silkworm"
    }
}

#Preview {
    ContentView()
}
