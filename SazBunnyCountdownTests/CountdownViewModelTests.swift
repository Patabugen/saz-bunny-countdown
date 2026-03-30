import Testing
import Foundation
@testable import SazBunnyCountdown

@MainActor
@Suite("CountdownViewModel")
struct CountdownViewModelTests {

    // MARK: - Start / Stop Lifecycle

    @Test("start sets initial state correctly")
    func startSetsState() {
        let vm = CountdownViewModel()
        let target = Date().addingTimeInterval(3600)
        vm.start(targetDate: target)

        #expect(vm.isFinished == false)
        #expect(vm.targetTimeString != nil)
        #expect(!vm.timeString.isEmpty)
    }

    @Test("stop clears timer state")
    func stopClearsState() {
        let vm = CountdownViewModel()
        vm.start(targetDate: Date().addingTimeInterval(3600))
        vm.stop()

        // After stop, updateDisplay should be a no-op (targetDate is nil)
        vm.updateDisplay()
        // timeString retains last value, but timer is stopped
        #expect(vm.isFinished == false)
    }

    @Test("start resets finished state from previous run")
    func startResetsFinished() {
        let vm = CountdownViewModel()
        // First run: finish immediately
        let past = Date().addingTimeInterval(-10)
        vm.start(targetDate: past)
        #expect(vm.isFinished == true)

        // Second run: new future target
        let future = Date().addingTimeInterval(3600)
        vm.start(targetDate: future)
        #expect(vm.isFinished == false)
    }

    // MARK: - Display Formatting

    @Test("formats minutes and seconds when under 1 hour")
    func formatMinutesSeconds() {
        let vm = CountdownViewModel()
        let now = Date()
        let target = now.addingTimeInterval(754) // 12m 34s
        vm.start(targetDate: target)
        vm.updateDisplay(now: now)

        #expect(vm.timeString == "12:34")
    }

    @Test("formats hours, minutes and seconds when 1 hour or more")
    func formatHoursMinutesSeconds() {
        let vm = CountdownViewModel()
        let now = Date()
        let target = now.addingTimeInterval(5025) // 1h 23m 45s
        vm.start(targetDate: target)
        vm.updateDisplay(now: now)

        #expect(vm.timeString == "1:23:45")
    }

    @Test("formats single-digit seconds with leading zero")
    func formatLeadingZero() {
        let vm = CountdownViewModel()
        let now = Date()
        let target = now.addingTimeInterval(61) // 1m 1s
        vm.start(targetDate: target)
        vm.updateDisplay(now: now)

        #expect(vm.timeString == "01:01")
    }

    @Test("formats exactly 1 minute remaining")
    func formatExactlyOneMinute() {
        let vm = CountdownViewModel()
        let now = Date()
        let target = now.addingTimeInterval(60)
        vm.start(targetDate: target)
        vm.updateDisplay(now: now)

        #expect(vm.timeString == "01:00")
    }

    @Test("formats large hour counts")
    func formatLargeHours() {
        let vm = CountdownViewModel()
        let now = Date()
        let target = now.addingTimeInterval(36000) // 10h 0m 0s
        vm.start(targetDate: target)
        vm.updateDisplay(now: now)

        #expect(vm.timeString == "10:00:00")
    }

    // MARK: - Finished State

    @Test("marks finished when target date is in the past")
    func finishedWhenPast() {
        let vm = CountdownViewModel()
        let past = Date().addingTimeInterval(-5)
        vm.start(targetDate: past)

        #expect(vm.isFinished == true)
        #expect(vm.timeString == "00:00")
    }

    @Test("marks finished when updateDisplay sees elapsed time")
    func finishedOnUpdate() {
        let vm = CountdownViewModel()
        let now = Date()
        let target = now.addingTimeInterval(30)
        vm.start(targetDate: target)

        #expect(vm.isFinished == false)

        // Simulate time passing beyond the target
        let later = now.addingTimeInterval(31)
        vm.updateDisplay(now: later)

        #expect(vm.isFinished == true)
        #expect(vm.timeString == "00:00")
    }

    @Test("isFinished only triggers once")
    func finishedTriggersOnce() {
        let vm = CountdownViewModel()
        let now = Date()
        let target = now.addingTimeInterval(10)
        vm.start(targetDate: target)

        let later = now.addingTimeInterval(11)
        vm.updateDisplay(now: later)
        #expect(vm.isFinished == true)

        // Calling again shouldn't change state
        vm.updateDisplay(now: later.addingTimeInterval(5))
        #expect(vm.isFinished == true)
        #expect(vm.timeString == "00:00")
    }

    // MARK: - Target Time String

    @Test("targetTimeString is formatted from target date")
    func targetTimeStringFormatted() {
        let vm = CountdownViewModel()
        let target = Date().addingTimeInterval(3600)
        vm.start(targetDate: target)

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let expected = formatter.string(from: target)

        #expect(vm.targetTimeString == expected)
    }

    // MARK: - Original Input & Repeat

    @Test("start stores original input")
    func startStoresOriginalInput() {
        let vm = CountdownViewModel()
        let target = Date().addingTimeInterval(3600)
        vm.start(targetDate: target, originalInput: "20 past")
        #expect(vm.originalInput == "20 past")
    }

    @Test("start without originalInput defaults to nil")
    func startWithoutOriginalInput() {
        let vm = CountdownViewModel()
        vm.start(targetDate: Date().addingTimeInterval(3600))
        #expect(vm.originalInput == nil)
    }

    @Test("stop clears original input")
    func stopClearsOriginalInput() {
        let vm = CountdownViewModel()
        vm.start(targetDate: Date().addingTimeInterval(3600), originalInput: "4:20 PM")
        vm.stop()
        #expect(vm.originalInput == nil)
    }

    @Test("repeatTargetDate is targetDate plus 1 hour")
    func repeatTargetDateIsOneHourLater() {
        let vm = CountdownViewModel()
        let target = Date()
        vm.start(targetDate: target)
        let expected = Calendar.current.date(byAdding: .hour, value: 1, to: target)!
        #expect(vm.repeatTargetDate == expected)
    }

    @Test("repeatTargetDate is nil after stop")
    func repeatTargetDateNilAfterStop() {
        let vm = CountdownViewModel()
        vm.start(targetDate: Date())
        vm.stop()
        #expect(vm.repeatTargetDate == nil)
    }

    @Test("repeatTargetDate is nil on fresh view model")
    func repeatTargetDateNilOnFresh() {
        let vm = CountdownViewModel()
        #expect(vm.repeatTargetDate == nil)
    }

    @Test("repeatTargetTimeString formats the repeat date")
    func repeatTargetTimeStringFormats() {
        let vm = CountdownViewModel()
        let target = Date()
        vm.start(targetDate: target)
        let expected = Calendar.current.date(byAdding: .hour, value: 1, to: target)!
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        #expect(vm.repeatTargetTimeString == formatter.string(from: expected))
    }

    @Test("chained repeats advance by 1 hour each time")
    func chainedRepeats() {
        let vm = CountdownViewModel()
        let original = Date()
        vm.start(targetDate: original)
        let first = vm.repeatTargetDate!
        vm.start(targetDate: first)
        let second = vm.repeatTargetDate!
        let expected = Calendar.current.date(byAdding: .hour, value: 2, to: original)!
        #expect(second == expected)
    }

    // MARK: - Edge Cases

    @Test("updateDisplay is no-op after stop")
    func updateAfterStop() {
        let vm = CountdownViewModel()
        let now = Date()
        vm.start(targetDate: now.addingTimeInterval(100))
        vm.updateDisplay(now: now)
        let timeAfterStart = vm.timeString

        vm.stop()
        vm.updateDisplay(now: now.addingTimeInterval(50))

        // timeString should not change after stop
        #expect(vm.timeString == timeAfterStart)
    }

    @Test("updateDisplay with exactly zero remaining marks finished")
    func exactlyZeroRemaining() {
        let vm = CountdownViewModel()
        let now = Date()
        vm.start(targetDate: now)
        vm.updateDisplay(now: now)

        #expect(vm.isFinished == true)
        #expect(vm.timeString == "00:00")
    }
}
