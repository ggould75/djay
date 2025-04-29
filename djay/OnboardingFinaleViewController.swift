import UIKit
import AVFoundation

extension OnboardingSkillLevel {
    var congratulationMessage: String {
        switch self {
        case .newbie: "WELCOME TO THE WORLD OF DJING • START YOUR JOURNEY • "
        case .experienced: "LEVEL UP YOUR DJ SKILLS • WELCOME BACK • "
        case .professional: "PRO DJ • MASTER THE MIX • DROP THE BEAT • "
        }
    }
}

final class OnboardingFinaleViewController: UIViewController, OnboardingPageContent {
    private enum Constants {
        static let vinylRecordDiameter = 200
        static let vinylRecordBeginTime = CACurrentMediaTime() + 2
    }

    // MARK: - OnboardingPageContent

    var navigationButtonTitle: String = "Done"
    var navigationButtonEnabledCallback: ((Bool) -> Void)?
    
    func navigationButtonTapped(completion: @escaping (OnboardingPageResult) -> Void) {
        completion(.proceed)
    }

    // MARK: Initialization

    let onboardingSkillLevel: OnboardingSkillLevel

    init(_ onboardingSkillLevel: OnboardingSkillLevel) {
        self.onboardingSkillLevel = onboardingSkillLevel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupAudio()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Given some time to the transition to this view controller to complete so that you don't see the content of this page sliding in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.startAnimation()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopAnimation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let containerBounds = animationContainerView.bounds

        if vinylRecordLayer.superlayer == nil {
            setupVinylRecordLayer()
        } else {
            let vinylRecordRadius = CGFloat(Constants.vinylRecordDiameter / 2)
            vinylRecordLayer.position = CGPoint(x: containerBounds.width / 2 - vinylRecordRadius,
                                                y: containerBounds.height / 2 - vinylRecordRadius)
        }

        if textOnPathLayer == nil {
            setupTextOnPathLayer()
        } else {
            updateTextPathPosition()
        }

        setupParticleLayers()

        if let particleEmitterLayer {
            particleEmitterLayer.isHidden = !isAnimationRunning
            particleEmitterLayer.emitterPosition = CGPoint(x: containerBounds.width / 2,
                                                           y: containerBounds.height / 2)
            if particleEmitterLayer.emitterSize == .zero {
                let particleEmitterSizeRatio = 0.25
                particleEmitterLayer.emitterSize = CGSize(width: containerBounds.width * particleEmitterSizeRatio,
                                                          height: containerBounds.height * particleEmitterSizeRatio)
            }
        }

        if let beatEmitterLayer {
            beatEmitterLayer.isHidden = !isAnimationRunning
            beatEmitterLayer.emitterPosition = CGPoint(x: containerBounds.width / 2,
                                                       y: containerBounds.height / 2)
        }
    }

    // MARK: - UIContentContainer

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Remove the existing emitters and recreate them after rotation to prevent particle scaling issues
        particleEmitterLayer?.removeFromSuperlayer()
        beatEmitterLayer?.removeFromSuperlayer()
        particleEmitterLayer = nil
        beatEmitterLayer = nil
        setupParticleLayers()
    }

    // MARK: - Subviews setup

    private let animationContainerView = UIView()

    private func setupViews() {
        animationContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationContainerView)

        NSLayoutConstraint.activate([
            animationContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            animationContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Layers and animation setup

    private let vinylRecordLayer = CAShapeLayer()

    private var particleEmitterLayer: CAEmitterLayer?
    private var beatEmitterLayer: CAEmitterLayer?

    private let textLayer = CATextLayer()
    private var textOnPathLayer: CALayer?

    private func setupVinylRecordLayer() {
        // Outer path
        let vinylPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: Constants.vinylRecordDiameter, height: Constants.vinylRecordDiameter))

        // Center path
        let centerHolePath = UIBezierPath(ovalIn: CGRect(x: 90, y: 90, width: 20, height: 20))
        vinylPath.append(centerHolePath)

        // Inner path
        let vinylRecordRadius = Constants.vinylRecordDiameter / 2
        let innerRingPath = UIBezierPath(ovalIn: CGRect(x: 50, y: 50, width: vinylRecordRadius, height: vinylRecordRadius))
        vinylPath.append(innerRingPath)

        vinylRecordLayer.path = vinylPath.cgPath
        vinylRecordLayer.fillColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 0.05).cgColor
        vinylRecordLayer.strokeColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0).cgColor
        vinylRecordLayer.lineWidth = 2.0
        vinylRecordLayer.position = CGPoint(x: view.bounds.width/2 - CGFloat(vinylRecordRadius),
                                            y: view.bounds.height/2 - CGFloat(vinylRecordRadius))
        vinylRecordLayer.opacity = 0

        animationContainerView.layer.addSublayer(vinylRecordLayer)
    }

    private func setupParticleLayers() {
        guard particleEmitterLayer == nil, beatEmitterLayer == nil else { return }

        // Main spectrum particle emitter
        let particleEmitter = CAEmitterLayer()
        particleEmitter.emitterShape = .circle
        particleEmitter.renderMode = .additive
        particleEmitter.isHidden = true

        var emitterCells: [CAEmitterCell] = []

        // Gold/yellow particles (matching logo color)
        let yellowCell = createEmitterCell(color: UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 0.8),
                                           velocity: 100,
                                           scale: 0.5,
                                           lifetime: 2.0)
        // Orange particles
        let orangeCell = createEmitterCell(color: UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 0.7),
                                           velocity: 120,
                                           scale: 0.4,
                                           lifetime: 1.8)
        // White particles for highlights
        let whiteCell = createEmitterCell(color: .white,
                                          velocity: 140,
                                          scale: 0.3,
                                          lifetime: 1.5)
        emitterCells.append(yellowCell)
        emitterCells.append(orangeCell)
        emitterCells.append(whiteCell)

        particleEmitter.emitterCells = emitterCells
        animationContainerView.layer.addSublayer(particleEmitter)
        self.particleEmitterLayer = particleEmitter

        // An emitter for following the music's beats
        let beatEmitter = CAEmitterLayer()
        beatEmitter.emitterShape = .circle
        beatEmitter.emitterSize = CGSize(width: 10, height: 10)
        beatEmitter.renderMode = .additive
        beatEmitter.birthRate = 0 // Start with no particles
        beatEmitter.isHidden = true

        let beatCell = createEmitterCell(color: UIColor(red: 1.0, green: 1.0, blue: 0.3, alpha: 0.9),
                                         velocity: 200,
                                         scale: 0.8,
                                         lifetime: 0.8)
        beatCell.birthRate = 20

        beatEmitter.emitterCells = [beatCell]
        animationContainerView.layer.addSublayer(beatEmitter)
        self.beatEmitterLayer = beatEmitter
    }

    private func createEmitterCell(color: UIColor, velocity: CGFloat, scale: CGFloat, lifetime: Float) -> CAEmitterCell {
        let cell = CAEmitterCell()

        // Create the particle's base image
        let size = CGSize(width: 8, height: 8)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fillEllipse(in: CGRect(origin: .zero, size: size))
        cell.contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        UIGraphicsEndImageContext()

        cell.birthRate = 8
        cell.lifetime = lifetime
        cell.lifetimeRange = lifetime / 4
        cell.velocity = velocity
        cell.velocityRange = velocity / 3
        cell.scale = scale
        cell.scaleRange = scale / 4
        cell.scaleSpeed = -0.1
        cell.emissionRange = .pi * 2
        cell.spin = 0.5
        cell.spinRange = 1.0
        cell.color = color.cgColor
        cell.alphaSpeed = -0.2
        cell.redSpeed = 0.1
        cell.blueSpeed = -0.1

        return cell
    }

    private func updateParticlesWithAmplitude(_ amplitude: Float) {
        // Scale amplitude to reasonable values
        let scaledAmplitude = min(2.0, amplitude * 10.0)

        // Update particle emitter properties based on amplitude
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        particleEmitterLayer?.emitterCells?.forEach { cell in
            cell.velocity = 100 + CGFloat(scaledAmplitude * 150)
            cell.scale = 0.5 + CGFloat(scaledAmplitude * 0.5)
        }

        // If amplitude exceeds threshold, emit a "beat" particle burst
        if scaledAmplitude > 0.8 {
            emitBeatParticles()
        }

        CATransaction.commit()
    }

    // Create a quick burst of larger particles on beat detection
    private func emitBeatParticles() {
        guard let beatEmitterLayer else { return }

        // Briefly increase birthrate then reduce it
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        beatEmitterLayer.beginTime = CACurrentMediaTime()
        beatEmitterLayer.birthRate = 20
        CATransaction.commit()

        // Reset birthrate after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            beatEmitterLayer.birthRate = 0
            CATransaction.commit()
        }
    }

    private func animateVinylRecord() {
        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.fromValue = 0
        fadeInAnimation.toValue = 1
        fadeInAnimation.duration = 2
        fadeInAnimation.beginTime = Constants.vinylRecordBeginTime
        fadeInAnimation.fillMode = .backwards
        fadeInAnimation.isRemovedOnCompletion = false

        let shimmerEffectAnimation = CABasicAnimation(keyPath: "strokeColor")
        shimmerEffectAnimation.fromValue = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0).cgColor
        shimmerEffectAnimation.toValue = UIColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0).cgColor
        shimmerEffectAnimation.duration = 2
        shimmerEffectAnimation.autoreverses = true
        shimmerEffectAnimation.repeatCount = Float.infinity
        shimmerEffectAnimation.beginTime = Constants.vinylRecordBeginTime
        shimmerEffectAnimation.fillMode = .backwards
        shimmerEffectAnimation.isRemovedOnCompletion = false

        vinylRecordLayer.add(fadeInAnimation, forKey: "fadeIn")
        vinylRecordLayer.add(shimmerEffectAnimation, forKey: "shimmer")

        vinylRecordLayer.opacity = 1
    }

    private func setupTextOnPathLayer() {
        // Get the vinyl position, which is at the top-left corner
        let vinylRecordRadius = CGFloat(Constants.vinylRecordDiameter / 2)
        let vinylCenterPoint = CGPoint(x: vinylRecordLayer.position.x + vinylRecordRadius,
                                       y: vinylRecordLayer.position.y + vinylRecordRadius)

        // Calculate the path radius - between outer and inner paths
        let innerRingRadius = CGFloat(Constants.vinylRecordDiameter / 4)
        let textPathRadius = (vinylRecordRadius + innerRingRadius) / 2

        // Create container layer for the text that will rotate
        let circularTextLayer = CALayer()
        circularTextLayer.position = vinylCenterPoint
        animationContainerView.layer.addSublayer(circularTextLayer)
        self.textOnPathLayer = circularTextLayer

        // Create individual character layers around the path
        let characters = Array(onboardingSkillLevel.congratulationMessage)
        let angleBetweenChars = (2.0 * .pi) / CGFloat(characters.count)

        for (index, character) in characters.enumerated() {
            let charLayer = CATextLayer()
            charLayer.string = String(character)
            charLayer.fontSize = 12
            charLayer.alignmentMode = .center
            charLayer.foregroundColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0).cgColor
            charLayer.frame = CGRect(x: -8, y: -8, width: 16, height: 16) // Center the character in its own frame

            // Calculate position on circle relative to the container's center
            let angle = CGFloat(index) * angleBetweenChars
            let x = textPathRadius * cos(angle)
            let y = textPathRadius * sin(angle)

            // Position and rotate each character to face outward from center
            charLayer.position = CGPoint(x: x, y: y)
            charLayer.transform = CATransform3DMakeRotation(angle + (.pi / 2), 0, 0, 1)

            circularTextLayer.addSublayer(charLayer)
        }

        circularTextLayer.opacity = 0
    }

    private func updateTextPathPosition() {
        guard let textOnPathLayer = textOnPathLayer else { return }

        let vinylRecordRadius = CGFloat(Constants.vinylRecordDiameter / 2)
        let vinylCenterX = vinylRecordLayer.position.x + vinylRecordRadius
        let vinylCenterY = vinylRecordLayer.position.y + vinylRecordRadius
        let vinylCenterPoint = CGPoint(x: vinylCenterX, y: vinylCenterY)

        textOnPathLayer.position = vinylCenterPoint
    }

    private func animateCircularText() {
        guard let textOnPathLayer else { return }

        // Rotate the whole text
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = 2 * Double.pi
        rotationAnimation.duration = 12 // Full rotation every 12 seconds
        rotationAnimation.repeatCount = Float.infinity
        rotationAnimation.beginTime = Constants.vinylRecordBeginTime
        rotationAnimation.isRemovedOnCompletion = false

        textOnPathLayer.add(rotationAnimation, forKey: "rotation")

        // Fade in the text after some delay
        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.fromValue = 0
        fadeInAnimation.toValue = 1
        fadeInAnimation.duration = 2.5
        fadeInAnimation.isRemovedOnCompletion = false
        fadeInAnimation.fillMode = .backwards
        fadeInAnimation.beginTime = Constants.vinylRecordBeginTime
        fadeInAnimation.isRemovedOnCompletion = false

        textOnPathLayer.add(fadeInAnimation, forKey: "fadeIn")
        textOnPathLayer.opacity = 1
    }

    // MARK: - Audio setup

    private var audioPlayer: AVAudioPlayer?
    private var audioEngine: AVAudioEngine?
    private var audioPlayerNode: AVAudioPlayerNode?
    private var audioFile: AVAudioFile?
    private var fftSize: UInt32 = 1024

    private func setupAudio() {
        guard let audioURL = Bundle.main.url(forResource: "finale-audio", withExtension: "mp3") else {
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.prepareToPlay()

            setupAudioEngine(with: audioURL)
        } catch {
            assertionFailure("Error loading audio: \(error.localizedDescription)")
        }
    }

    private func setupAudioEngine(with url: URL) {
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()

        guard let audioEngine, let audioPlayerNode else { return }

        do {
            audioFile = try AVAudioFile(forReading: url)
            audioEngine.attach(audioPlayerNode)

            // Add a tap to monitor audio output
            let mixer = audioEngine.mainMixerNode
            let format = mixer.outputFormat(forBus: 0)

            audioEngine.connect(audioPlayerNode, to: mixer, format: format)

            // Install tap to get PCM buffer data for visualization
            mixer.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
                self?.processAudioBuffer(buffer)
            }

            try audioEngine.start()

        } catch {
            assertionFailure("Error setting up audio engine: \(error.localizedDescription)")
        }
    }

    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        // Simple amplitude detection for demo purposes
        guard let channelData = buffer.floatChannelData?[0] else { return }

        let frameCount = Int(buffer.frameLength)
        var sum: Float = 0

        for i in 0 ..< frameCount {
            let amplitude = abs(channelData[i])
            sum += amplitude
        }

        // The average amplitude
        let avgAmplitude = sum / Float(frameCount)

        // Use this amplitude to drive particle animation
        DispatchQueue.main.async { [weak self] in
            self?.updateParticlesWithAmplitude(avgAmplitude)
        }
    }

    private func scheduleAudioStart() {
        guard let audioFile else { return }

        audioPlayerNode?.scheduleFile(audioFile, at: nil, completionCallbackType: .dataPlayedBack) { [weak self] _ in
            // Restart again the audio file when complete
            self?.scheduleAudioStart()
        }
    }

    // MARK: - Start/Stop animation

    private var isAnimationRunning = false

    private func startAnimation() {
        guard !isAnimationRunning else { return }

        isAnimationRunning = true

        setupParticleLayers()
        particleEmitterLayer?.isHidden = false
        beatEmitterLayer?.isHidden = false

        animateCircularText()
        animateVinylRecord()

        scheduleAudioStart()
        audioPlayerNode?.play()
    }

    private func stopAnimation() {
        guard isAnimationRunning else { return }

        audioPlayerNode?.stop()
        audioEngine?.stop()

        audioEngine?.mainMixerNode.removeTap(onBus: 0)

        vinylRecordLayer.removeAllAnimations()
        textOnPathLayer?.removeAllAnimations()

        isAnimationRunning = false
    }
}
