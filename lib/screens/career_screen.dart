import 'package:flutter/material.dart';
import 'package:og_vibes_student/widgets/vibe_scaffold.dart';

class CareerScreen extends StatefulWidget {
  const CareerScreen({super.key});

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VibeScaffold(
      appBar: AppBar(
        title: const Text('Career & Funding'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.school),
              text: 'Bursaries',
            ),
            Tab(
              icon: Icon(Icons.business),
              text: 'Internships',
            ),
            Tab(
              icon: Icon(Icons.work),
              text: 'Jobs',
            ),
            Tab(
              icon: Icon(Icons.paid),
              text: 'Funding',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBursariesTab(),
          _buildInternshipsTab(),
          _buildJobsTab(),
          _buildFundingTab(),
        ],
      ),
    );
  }

  Widget _buildBursariesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCardHeader(
          'Available Bursaries',
          'Explore financial assistance programs',
        ),
        const SizedBox(height: 16),
        _buildBursaryCard(
          title: 'Merit-Based Bursaries',
          description: 'Scholarships based on academic excellence',
          icon: Icons.star,
          color: Colors.amber,
        ),
        const SizedBox(height: 12),
        _buildBursaryCard(
          title: 'Need-Based Bursaries',
          description: 'Financial aid for students in need',
          icon: Icons.support,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildBursaryCard(
          title: 'Faculty-Specific Bursaries',
          description: 'Support for specific academic departments',
          icon: Icons.school,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildBursaryCard(
          title: 'External Bursaries',
          description: 'Opportunities from external organizations',
          icon: Icons.business,
          color: Colors.purple,
        ),
        const SizedBox(height: 12),
        _buildBursaryCard(
          title: 'Sports & Arts Bursaries',
          description: 'Support for talented athletes and artists',
          icon: Icons.sports_soccer,
          color: Colors.red,
        ),
        const SizedBox(height: 30),
        _buildActionButton('View All Bursaries', Colors.amber),
      ],
    );
  }

  Widget _buildInternshipsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCardHeader(
          'Current Internships',
          'Gain real-world experience',
        ),
        const SizedBox(height: 16),
        _buildInternshipCard(
          company: 'Tech Corp',
          position: 'Software Development Intern',
          duration: '6 months',
          icon: Icons.code,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildInternshipCard(
          company: 'Creative Agency',
          position: 'Graphic Design Intern',
          duration: '4 months',
          icon: Icons.palette,
          color: Colors.pink,
        ),
        const SizedBox(height: 12),
        _buildInternshipCard(
          company: 'Finance Ltd',
          position: 'Finance & Accounting Intern',
          duration: '6 months',
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildInternshipCard(
          company: 'Marketing Solutions',
          position: 'Digital Marketing Intern',
          duration: '3 months',
          icon: Icons.trending_up,
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildInternshipCard(
          company: 'Legal Services',
          position: 'Legal Intern',
          duration: '6 months',
          icon: Icons.gavel,
          color: Colors.indigo,
        ),
        const SizedBox(height: 30),
        _buildActionButton('Browse All Internships', Colors.blue),
      ],
    );
  }

  Widget _buildJobsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCardHeader(
          'Job Opportunities',
          'Find graduate and part-time positions',
        ),
        const SizedBox(height: 16),
        _buildJobCard(
          company: 'Corporate Solutions',
          position: 'Junior Software Engineer',
          type: 'Full-time',
          salary: 'R15,000 - R20,000/month',
          icon: Icons.computer,
        ),
        const SizedBox(height: 12),
        _buildJobCard(
          company: 'University Services',
          position: 'Student Tutor (Part-time)',
          type: 'Part-time',
          salary: 'R150/hour',
          icon: Icons.school,
        ),
        const SizedBox(height: 12),
        _buildJobCard(
          company: 'Retail Chain',
          position: 'Campus Ambassador',
          type: 'Part-time',
          salary: 'R200/hour + commission',
          icon: Icons.shopping_bag,
        ),
        const SizedBox(height: 12),
        _buildJobCard(
          company: 'Consulting Firm',
          position: 'Business Analyst',
          type: 'Full-time',
          salary: 'R25,000 - R30,000/month',
          icon: Icons.analytics,
        ),
        const SizedBox(height: 12),
        _buildJobCard(
          company: 'Tech Startup',
          position: 'UI/UX Designer',
          type: 'Full-time',
          salary: 'R18,000 - R24,000/month',
          icon: Icons.design_services,
        ),
        const SizedBox(height: 30),
        _buildActionButton('View All Jobs', Colors.green),
      ],
    );
  }

  Widget _buildFundingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCardHeader(
          'Alternative Funding',
          'Explore diverse funding opportunities',
        ),
        const SizedBox(height: 16),
        _buildFundingCard(
          title: 'Study Loans',
          description: 'Affordable education loans with flexible repayment',
          icon: Icons.account_balance,
          color: Colors.teal,
        ),
        const SizedBox(height: 12),
        _buildFundingCard(
          title: 'Government Grants',
          description: 'Non-repayable financial aid from government',
          icon: Icons.public,
          color: Colors.deepOrange,
        ),
        const SizedBox(height: 12),
        _buildFundingCard(
          title: 'Corporate Sponsorships',
          description: 'Support from major companies and corporations',
          icon: Icons.corporate_fare,
          color: Colors.indigo,
        ),
        const SizedBox(height: 12),
        _buildFundingCard(
          title: 'NGO Support',
          description: 'Assistance from non-governmental organizations',
          icon: Icons.favorite,
          color: Colors.red,
        ),
        const SizedBox(height: 12),
        _buildFundingCard(
          title: 'Crowdfunding',
          description: 'Connect with fundraising platforms',
          icon: Icons.groups,
          color: Colors.lightBlue,
        ),
        const SizedBox(height: 30),
        _buildActionButton('Explore Funding Options', Colors.teal),
      ],
    );
  }

  Widget _buildCardHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildBursaryCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening $title details...')),
          );
        },
      ),
    );
  }

  Widget _buildInternshipCard({
    required String company,
    required String position,
    required String duration,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        position,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                duration,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard({
    required String company,
    required String position,
    required String type,
    required String salary,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        position,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    type,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    salary,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundingCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening $title details...')),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(String label, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigating to $label...')),
          );
        },
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
