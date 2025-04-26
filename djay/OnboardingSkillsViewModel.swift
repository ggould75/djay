import Foundation

final class OnboardingSkillsViewModel {
    enum SkillLevel: String, CaseIterable {
        case newbie = "I'm new to DJing"
        case experienced = "I've used DJ apps before"
        case professional = "I'm a professional DJ"
    }

    var skillCount: Int {
        return SkillLevel.allCases.count
    }

    var selectedIndexPath: IndexPath?

    func skillLevel(at indexPath: IndexPath) -> SkillLevel {
        return SkillLevel.allCases[indexPath.section]
    }

    func indexPath(for skillLevel: SkillLevel) -> IndexPath? {
        guard let rowIndex = skillLevel.index else {
            return nil
        }

        return IndexPath(row: 1, section: rowIndex)
    }
}
