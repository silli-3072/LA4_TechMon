//
//  BottleViewController.swift
//  TechMon
//
//  Created by 春田実利 on 2022/08/30.
//

import UIKit

class BottleViewController: UIViewController {
    
    @IBOutlet var playerNameLabel: UILabel!
    @IBOutlet var playerImageView: UIImageView!
    @IBOutlet var playerHPLabel: UILabel!
    @IBOutlet var playerMPLabel: UILabel!
    @IBOutlet var playerTPLabel: UILabel!
    
    @IBOutlet var enemyNameLabel: UILabel!
    @IBOutlet var enemyImageView: UIImageView!
    @IBOutlet var enemyHPLabel: UILabel!
    @IBOutlet var enemyMPLabel: UILabel!
    
    let techMonManager = TechMonManager.shared
    
    var playerHP = 100
    var playerMP = 0
    var enemyHP = 200
    var enemyMP = 0
    
    var gameTimer: Timer!
    var isPlayerAttackAvilabel: Bool = true
    
    var player: Character!
    var enemy: Character!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerNameLabel.text = "勇者"
        playerImageView.image = UIImage(named: "yusya.png")
        playerHPLabel.text = "\(playerHP) / 100"
        playerMPLabel.text = "\(playerMP) / 20"
        
        enemyNameLabel.text = "龍"
        enemyImageView.image = UIImage(named: "monster.png")
        enemyHPLabel.text = "\(enemyHP) / 200"
        enemyMPLabel.text = "\(enemyMP) / 35"
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateGame), userInfo: nil, repeats: true)
        
        gameTimer.fire()
        
        player = techMonManager.player
        enemy = techMonManager.enemy
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        techMonManager.playBGM(fileName: "BGM_battle001")
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        techMonManager.stopBGM()
        
    }
    
    @objc func updateGame() {
        playerMP += 1
        
        if playerMP >= 20 {
            isPlayerAttackAvilabel = true
            playerMP = 20
        } else {
            isPlayerAttackAvilabel = false
        }
        
        enemyMP += 1
        
        if enemyMP >= 35 {
            enemyAttack()
            enemyMP = 0
        }
        
        playerMPLabel.text = "\(playerMP) / 20"
        enemyMPLabel.text = "\(enemyMP) / 35"
    }
    
    func enemyAttack() {
        techMonManager.damageAnimation(imageView: playerImageView)
        techMonManager.playSE(fileName: "SE_attack")
        
        playerHP -= 20
        playerHPLabel.text = "\(playerHP) / 100"
        
        if playerHP <= 0 {
            finishBattle(vanishImageView: playerImageView, isPayerWin: false)
        }
        
    }
    
    func finishBattle(vanishImageView: UIImageView, isPayerWin: Bool) {
        techMonManager.vanishAnimation(imageView: vanishImageView)
        techMonManager.stopBGM()
        gameTimer.invalidate()
        isPlayerAttackAvilabel = false
        
        var finishMessage: String = ""
        if isPayerWin {
            techMonManager.playSE(fileName: "SE_fanfare")
            finishMessage = "勇者の勝利!!"
        } else {
            techMonManager.playSE(fileName: "SE_gameover")
            finishMessage = "勇者の敗北"
        }
        
        let alert = UIAlertController(title: "バトル終了", message: finishMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in self.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion:  nil)
    }
    
    @IBAction func attackAction() {
        if isPlayerAttackAvilabel {
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_attack")
            
            enemyHP -= 30
            enemyHPLabel.text = "\(enemyHP) / 200"
            
            playerMP = 0
            playerMPLabel.text = "\(playerMP) / 20"
            
            if enemyHP <= 0 {
                finishBattle(vanishImageView: enemyImageView, isPayerWin: true)
            }
            
            player.currentTP += 10
            playerTPLabel.text = "\(player.currentTP) / \(player.maxTP)"
            
            if player.currentTP >= player.maxTP {
                player.currentTP = player.maxTP
            }
            
            
        }
    }
    
    func updateUI(){
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)"
        playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)"
        playerTPLabel.text = "\(player.currentTP) / \(player.maxTP)"
        
        enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
        enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)"
        
    }
    
    func judgeButtle(){
        if player.currentHP <= 0 {
            finishBattle(vanishImageView: playerImageView, isPayerWin: false)
        } else if enemy.currentHP <= 0 {
            finishBattle(vanishImageView: enemyImageView, isPayerWin: true)
        }
    }
    
    @IBAction func tameruAction() {
        if isPlayerAttackAvilabel {
            techMonManager.playSE(fileName: "SE_charge")
            player.currentTP += 40
            
            
            player.currentMP = 0
            
            playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)"
            playerTPLabel.text = "\(player.currentTP) / \(player.maxTP)"
            
            if player.currentTP >= player.maxTP {
                player.currentTP = player.maxTP
            }
        }
    }
    
    @IBAction func fireAction() {
        if isPlayerAttackAvilabel && player.currentTP >= 40 {
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_fire")
            
            enemy.currentHP -= 100
            
            player.currentTP -= 40
            if player.currentTP <= 0 {
                player.currentTP = 0
            }
            player.currentMP = 0
            
            updateUI()
            judgeButtle()
        }
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
