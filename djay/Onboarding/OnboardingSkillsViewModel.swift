import Foundation

enum OnboardingSkillLevel: String, CaseIterable {
    case newbie = "I'm new to DJing"
    case experienced = "I've used DJ apps before"
    case professional = "I'm a professional DJ"
}

final class OnboardingSkillsViewModel {
    var skillCount: Int {
        return OnboardingSkillLevel.allCases.count
    }

    var selectedIndexPath: IndexPath?
    var selectedSkillLevel: OnboardingSkillLevel? {
        guard let selectedIndexPath else { return nil }

        return skillLevel(at: selectedIndexPath)
    }

    func skillLevel(at indexPath: IndexPath) -> OnboardingSkillLevel {
        return OnboardingSkillLevel.allCases[indexPath.section]
    }
}
